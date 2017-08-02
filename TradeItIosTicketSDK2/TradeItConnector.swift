public extension TradeItConnector {
    
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
            if result.status != "ERROR" { // Try to cast to desired resultClass
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
            let session = URLSession.shared
            session.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data,
                    let json = String(data: data, encoding: .utf8),
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 {
                    var result = TradeItResultTransformer.transform(targetClassType: TradeItResult.self, json: json)

                    if result?.status == "ERROR" { // Server sent an ERROR response so try create a TradeItErrorResult
                        let errorResult = TradeItResultTransformer.transform(targetClassType: TradeItErrorResult.self, json: json)
                        result = errorResult
                    }

                    let finalResult = result ?? TradeItErrorResult.error(withSystemMessage: "Server returned non TradeItResult")

                    DispatchQueue.main.async {
                        completionBlock(finalResult, json)
                    }
                } else {
                    // TODO: Figure out what to do here? httpResponse failed or similar
                    completionBlock(TradeItErrorResult.error(withSystemMessage: "Data Error"), nil)
                }
            }).resume()
        }
    }
}
