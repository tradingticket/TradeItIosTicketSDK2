@objc public protocol MarketDataService {
    @objc func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    )
}

@objc public class TradeItSymbolService: NSObject {
    let connector: TradeItConnector

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    public func symbolLookup(_ searchText: String, onSuccess: @escaping ([TradeItSymbolLookupCompany]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let symbolLookupRequest = TradeItSymbolLookupRequest(query: searchText)

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: symbolLookupRequest,
            emsAction: "marketdata/symbolLookup",
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItSymbolLookupResult.self, withCompletionBlock: { result in
            if let symbolLookupResult = result as? TradeItSymbolLookupResult,
                let results = symbolLookupResult.results as? [TradeItSymbolLookupCompany] {
                onSuccess(results)
            } else if let errorResult = result as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Symbol lookup failure", message: "Could not search for symbol. Please try again."))
            }
        })
    }

    public func fxSymbols(forBroker broker: String, onSuccess: @escaping ([String]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let requestData = TradeItFxSymbolsRequest()
        requestData.broker = broker
        requestData.apiKey = self.connector.apiKey

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: requestData,
            emsAction: "brokermarketdata/getFxCurrencyPairs",
            environment: self.connector.environment
        )

        // TODO: Fix this. Our connector doesn't support a way to just get back a string array from JSON.
        self.connector.sendReturnJSON(request, withCompletionBlock: { result, jsonResponse in
            if let data = jsonResponse.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)),
                let symbolsTemp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String],
                let symbols = symbolsTemp {
                onSuccess(symbols)
            } else {
                let jsonString = jsonResponse as String?
                let errorResult = TradeItRequestResultFactory.build(TradeItErrorResult(), jsonString: jsonString) as? TradeItErrorResult
                onFailure(errorResult ?? TradeItErrorResult.error(withSystemMessage: "Failed to fetch FX symbols"))
            }
        })
    }
}

@objc public class TradeItMarketService: NSObject, MarketDataService {
    let connector: TradeItConnector

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    public func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let quoteRequest = TradeItQuotesRequest(symbol: symbol)

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: quoteRequest,
            emsAction: getEndpoint(forRequest: quoteRequest),
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItQuotesResult.self, withCompletionBlock: { result in
            if let quotesResult = result as? TradeItQuotesResult,
                let quote = quotesResult.quotes?.first as? TradeItQuote {
                onSuccess(quote)
            } else if let errorResult = result as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Market data failure", message: "Could not fetch quote. Please try again."))
            }
        })
    }

    private func getEndpoint(forRequest request: TradeItQuotesRequest) -> String? {
        if request.suffixMarket != nil {
            return "marketdata/getYahooQuotes"
        } else if request.symbol != nil {
            return "marketdata/getQuote"
        } else if request.symbols != nil {
            return "marketdata/getQuotes"
        } else {
            return nil
        }
    }
}
