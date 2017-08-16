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
            if !result.isError() { // Try to cast to desired resultClass
                completionBlock(TradeItResultTransformer.transform(targetClassType: targetClassType, json: json))
            } else {
                completionBlock(result) // Error case
            }
        }
    }

    // MARK: Private
    
    private func send(
        _ request: URLRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult, String?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            let session = URLSession.init(configuration: config)
            
            session.dataTask(with: request, completionHandler: { data, response, error in
                let (result, json) = self.processResponse(data, response, error)

                DispatchQueue.main.async { completionBlock(result, json) }
            }).resume()
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
        }

        let defaultedResult = result ?? TradeItErrorResult.error(withSystemMessage: "JSON from server does not match the TradeItResult format.")

        return (defaultedResult, json)
    }
}
