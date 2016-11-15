class TradeItMarketService {
    var connector: TradeItConnector
    var sessionProvider: TradeItSessionProvider

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        sessionProvider = TradeItSessionProvider()
    }

    func getQuote(_ symbol: String, onSuccess: @escaping (TradeItQuote) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let session = sessionProvider.provide(connector: connector)
        let marketDataService = TradeItMarketDataService(session: session)
        let quotesRequest = TradeItQuotesRequest(symbol: symbol)

        marketDataService?.getQuoteData(quotesRequest, withCompletionBlock: { tradeItResult in
            if let quotesResult = tradeItResult as? TradeItQuotesResult,
                let quote = quotesResult.quotes?.first as? TradeItQuote {
                onSuccess(quote)
            } else if let errorResult = tradeItResult as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Market Data failed", message: "Fetching the quote failed. Please try again later."))
            }
        })
    }
    
    public func symbolLookup(_ searchText: String, onSuccess: @escaping ([TradeItSymbolLookupCompany]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let session = sessionProvider.provide(connector: connector)
        let marketDataService = TradeItMarketDataService(session: session)
        let symbolLookupRequest = TradeItSymbolLookupRequest(query: searchText)
        
        marketDataService?.symbolLookup(symbolLookupRequest, withCompletionBlock: { tradeItResult in
            
            if let symbolLookupResult = tradeItResult as? TradeItSymbolLookupResult,
                let results = symbolLookupResult.results as? [TradeItSymbolLookupCompany] {
                onSuccess(results)
            } else if let errorResult = tradeItResult as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Market Data failed", message: "Fetching data for symbol lookup failed. Please try again later."))
            }
        })
    }
}
