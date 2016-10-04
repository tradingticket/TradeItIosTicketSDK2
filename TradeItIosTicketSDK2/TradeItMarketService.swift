import TradeItIosEmsApi

class TradeItMarketService {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider

    init(connector: TradeItConnector) {
        tradeItConnector = connector
        tradeItSessionProvider = TradeItSessionProvider()
    }

    func getQuote(symbol: String, onSuccess: (TradeItQuote) -> Void, onFailure: (TradeItErrorResult) -> Void) {
        let session = tradeItSessionProvider.provide(connector: tradeItConnector)
        let quoteService = TradeItMarketDataService(session: session)
        let quotesRequest = TradeItQuotesRequest(symbol: symbol)

        quoteService.getQuoteData(quotesRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) in
            if let quotesResult = tradeItResult as? TradeItQuotesResult,
                let quote = quotesResult.quotes.first as? TradeItQuote {
                onSuccess(quote)
            } else if let errorResult = tradeItResult as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Error loading market data quote. Please try again later."))
            }
        })
    }
}
