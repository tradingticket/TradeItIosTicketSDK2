@objc public class TradeItSymbolService: NSObject {
    let connector: TradeItConnector

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    @objc public func symbolLookup(_ searchText: String, onSuccess: @escaping ([TradeItSymbolLookupCompany]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let symbolLookupRequest = TradeItSymbolLookupRequest(query: searchText)

        let request = TradeItRequestFactory.buildJsonRequest(
            for: symbolLookupRequest,
            emsAction: "marketdata/symbolLookup",
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItSymbolLookupResult.self, withCompletionBlock: { result in
            if let symbolLookupResult = result as? TradeItSymbolLookupResult,
                let results = symbolLookupResult.results {
                onSuccess(results)
            } else if let errorResult = result as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Symbol lookup failure", message: "Could not search for symbol. Please try again."))
            }
        })
    }

    @objc public func fxSymbols(forBroker broker: String, onSuccess: @escaping ([String]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let requestData = TradeItFxSymbolsRequest()
        requestData.broker = broker
        requestData.apiKey = self.connector.apiKey

        let request = TradeItRequestFactory.buildJsonRequest(
            for: requestData,
            emsAction: "brokermarketdata/getFxCurrencyPairs",
            environment: self.connector.environment
        )
        
        // TODO: Fix this. Our connector doesn't support a way to just get back a string array from JSON.
        self.connector.sendReturnJSON(request, withCompletionBlock: { result, jsonResponse in
            if let data = jsonResponse?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)),
                let symbolsTemp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String],
                let symbols = symbolsTemp {
                onSuccess(symbols)
            } else {
                let jsonString = jsonResponse as String?
                let errorResult =  TradeItResultTransformer.transform(targetClassType: TradeItErrorResult.self, json: jsonString)
                onFailure(errorResult ?? TradeItErrorResult.error(withSystemMessage: "Failed to fetch FX symbols"))
            }
        })
    }
}
