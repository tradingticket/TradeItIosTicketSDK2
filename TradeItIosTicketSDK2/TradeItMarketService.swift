class TradeItMarketService {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        // TODO: TradeItConnector initializer returns optional - we should not force unwrap
        tradeItConnector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)!
        tradeItSessionProvider = TradeItSessionProvider()
    }

    func getQuote(symbol: String, onSuccess: (TradeItQuote) -> Void, onFailure: (TradeItErrorResult) -> Void) {
        let session = tradeItSessionProvider.provide(connector: tradeItConnector)
        let marketDataService = TradeItMarketDataService(session: session)
        let quotesRequest = TradeItQuotesRequest(symbol: symbol)

        marketDataService.getQuoteData(quotesRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) in
            if let quotesResult = tradeItResult as? TradeItQuotesResult,
                let quote = quotesResult.quotes?.first as? TradeItQuote {
                onSuccess(quote)
            } else if let errorResult = tradeItResult as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Error loading market data quote. Please try again later."))
            }
        })
    }
    
    func symbolLookup(searchText: String, onSuccess: ([TradeItSymbolLookupCompany]) -> Void, onFailure: (TradeItErrorResult) -> Void) {
        let session = tradeItSessionProvider.provide(connector: tradeItConnector)
        let marketDataService = TradeItMarketDataService(session: session)
        let symbolLookupRequest = TradeItSymbolLookupRequest(query: searchText)
        
        marketDataService.symbolLookup(symbolLookupRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) in
            
            if let symbolLookupResult = tradeItResult as? TradeItSymbolLookupResult,
                let results = symbolLookupResult.results as? [TradeItSymbolLookupCompany] {
                onSuccess(results)
            } else if let errorResult = tradeItResult as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Error loading market data symbolLookup. Please try again later."))
            }
        })
    }
}
