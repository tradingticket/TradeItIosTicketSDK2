@objc public class TradeItPortfolioPosition : NSObject {
    public var position: TradeItPosition?
    public var fxPosition: TradeItFxPosition?
    var quote: TradeItQuote?
    var tradeItMarketDataService: TradeItMarketDataService
    unowned var linkedBrokerAccount: TradeItLinkedBrokerAccount

    static let fxMaximumFractionDigits = 5

    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, position: TradeItPosition) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.position = position
        self.tradeItMarketDataService = TradeItMarketDataService(session: self.linkedBrokerAccount.linkedBroker.session)
    }

    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, fxPosition: TradeItFxPosition) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.fxPosition = fxPosition
        self.tradeItMarketDataService = TradeItMarketDataService(session: linkedBrokerAccount.linkedBroker.session)
    }

    func refreshQuote(onFinished onFinished: () -> Void) {
        var tradeItQuoteRequest: TradeItQuotesRequest?
        var symbol = ""
        self.quote = nil

        if let position = self.position,  let equitySymbol = position.symbol {
            symbol = equitySymbol
            tradeItQuoteRequest = TradeItQuotesRequest(symbol: symbol)
        } else if let fxPosition = self.fxPosition, let fxSymbol = fxPosition.symbol {
            symbol = fxSymbol
            tradeItQuoteRequest = TradeItQuotesRequest(fxSymbol: symbol, andBroker: self.linkedBrokerAccount.brokerName)
        } else {
            onFinished()
            return
        }

        self.tradeItMarketDataService.getQuoteData(tradeItQuoteRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
            if let quotesResult = tradeItResult as? TradeItQuotesResult, let quotes = quotesResult.quotes as? [TradeItQuote] {
                self.quote = quotes.filter { return $0.symbol == symbol }.first
            }

            onFinished()
        })
    }
}
