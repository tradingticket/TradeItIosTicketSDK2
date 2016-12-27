@objc public class TradeItMarketService: NSObject {
    let marketDataService: TradeItMarketDataService

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        let connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        marketDataService = TradeItMarketDataService(connector: connector)
    }

    public func symbolLookup(_ searchText: String, onSuccess: @escaping ([TradeItSymbolLookupCompany]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let symbolLookupRequest = TradeItSymbolLookupRequest(query: searchText)

        self.marketDataService.symbolLookup(symbolLookupRequest, withCompletionBlock: { tradeItResult in
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

    func getQuote(_ symbol: String, onSuccess: @escaping (TradeItQuote) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let quotesRequest = TradeItQuotesRequest(symbol: symbol)

        getQuote(quoteRequest: quotesRequest, onSuccess: onSuccess, onFailure: onFailure)
    }

    func getFXQuote(_ symbol: String, broker: String, onSuccess: @escaping (TradeItQuote) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let quotesRequest = TradeItQuotesRequest(fxSymbol: symbol, andBroker: broker)

        getQuote(quoteRequest: quotesRequest, onSuccess: onSuccess, onFailure: onFailure)
    }

    private func getQuote(quoteRequest: TradeItQuotesRequest, onSuccess: @escaping (TradeItQuote) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.marketDataService.getQuoteData(quoteRequest, withCompletionBlock: { result in
            if let quotesResult = result as? TradeItQuotesResult,
                let quote = quotesResult.quotes?.first as? TradeItQuote {
                onSuccess(quote)
            } else if let errorResult = result as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Market Data failed", message: "Fetching the quote failed. Please try again later."))
            }
        })
    }
}
