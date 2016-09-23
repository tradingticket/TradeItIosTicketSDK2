import TradeItIosEmsApi
import PromiseKit

class TradeItError: ErrorType {

}

class TradeItQuoteManager {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider

    init(connector: TradeItConnector) {
        tradeItConnector = connector
        tradeItSessionProvider = TradeItSessionProvider()
    }

    func getQuote(symbol: String) -> Promise<TradeItQuote> {
        return Promise<TradeItQuote> { fulfill, reject in
            let session = tradeItSessionProvider.provide(connector: tradeItConnector)
            let quoteService = TradeItMarketDataService(session: session) // Possibly nil session?
            let quotesRequest = TradeItQuotesRequest(symbol: symbol)

            quoteService.getQuoteData(quotesRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) in
                if let quotesResult = tradeItResult as? TradeItQuotesResult {
                    let quote = quotesResult.quotes[0] as! TradeItQuote// TODO: Check if any?
                    fulfill(quote)
                } else if let errorResult = tradeItResult as? TradeItErrorResult {
                    print(errorResult)
                    return reject(TradeItError())
                } else {
                    return reject(TradeItError())
                }
            })
        }
    }
}
