import PromiseKit

private let LOG_TRAFFIC = false // Set to true to log requests/responses

internal extension TradeItConnector {
    func userToken(fromKeychainId keychainId: String) -> String? {
        return TradeItKeychain.getStringForKey(keychainId)
    }
    
    func sendReturnJSON(
        _ request: URLRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult, String?) -> Void
    ) {
        self.send(request, withCompletionBlock: completionBlock)
    }

    func send<T: TradeItResult>(
        _ request: URLRequest,
        targetClassType: T.Type,
        withCompletionBlock completionBlock: @escaping (TradeItResult?) -> Void
    ) {
        self.send(request) { result, json in
            if result.isSuccessful() { // Try to cast to desired resultClass
                completionBlock(TradeItResultTransformer.transform(targetClassType: targetClassType, json: json))
            } else {
                completionBlock(result) // Review order or Security question or Error case
            }
        }
    }

    func send<T: TradeItResult>(
        _ request: URLRequest,
        targetClassType: T.Type
    ) -> Promise<T> {
        return Promise<T> { fulfill, reject in
            send(request, targetClassType: targetClassType) { result in
                switch(result) {
                case let result as T: fulfill(result)
                case let error as TradeItErrorResult: reject(error)
                default:
                    reject(
                        TradeItErrorResult(title: "Could not retrieve UI config. Please try again.")
                    )
                }
            }
        }
    }

    // MARK: Private
    
    private func send(
        _ request: URLRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult, String?) -> Void
    ) {
        guard !TradeItSDK.isDeviceJailbroken else {
            completionBlock(
                TradeItErrorResult(
                    title: "This device is jailbroken",
                    message: "This action is not allowed on a jailbroken device"
                ), ""
            )
            return
        }
        
        if LOG_TRAFFIC {
            let requestBodyString = String(data: request.httpBody ?? Data(), encoding: String.Encoding.utf8)
            print("\n===== REQUEST =====\n\(request.url?.absoluteString ?? "NO URL!")\n\(requestBodyString ?? "NO BODY!")\n")
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.dataTask(
                with: request,
                completionHandler: { data, response, error in
                    if LOG_TRAFFIC {
                        let responseBodyString = String(data: data ?? Data(), encoding: String.Encoding.utf8)
                        print("\n===== RESPONSE =====\n\(request.url?.absoluteString ?? "NO URL!")\n\(responseBodyString ?? "NO BODY!")\n")
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        }
                    }

                    let (result, json) = self.processResponse(data, response, error)

                    DispatchQueue.main.async { completionBlock(result, json) }
                }
            ).resume()
        }
    }

    private func processResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> (TradeItResult, String?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (TradeItErrorResult.error(withSystemMessage: "Unable to cast response to HTTPUrlResponse. Error description message: \(error?.localizedDescription ?? "nil")"), nil)
        }

        guard httpResponse.statusCode == 200 else {
            return (TradeItErrorResult.error(withSystemMessage: "Response status code: \(httpResponse.statusCode)."), nil)
        }

        guard let data = data, let json = String(data: data, encoding: .utf8) else {
            return (TradeItErrorResult.error(withSystemMessage: "Unable to read JSON data."), nil)
        }

        var result = TradeItResultTransformer.transform(targetClassType: TradeItResult.self, json: json)

        if result?.isError() == true { // Server sent an ERROR response so try create a TradeItErrorResult
            result = TradeItResultTransformer.transform(targetClassType: TradeItErrorResult.self, json: json)
        } else if result?.isSecurityQuestion() == true {
            result = TradeItResultTransformer.transform(targetClassType: TradeItSecurityQuestionResult.self, json: json)
        }

        let defaultedResult = result ?? TradeItErrorResult.error(withSystemMessage: "JSON from server does not match the TradeItResult format.")

        return (defaultedResult, json)
    }
}
