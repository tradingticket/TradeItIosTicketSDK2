import TradeItIosEmsApi

class TradeItPortfolioPosition : NSObject {
    var position: TradeItPosition?
    var fxPosition: TradeItFxPosition?
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

        if let position = self.position, let equitySymbol = position.symbol {
            symbol = equitySymbol
            tradeItQuoteRequest = TradeItQuotesRequest(symbol: symbol)
        }

        if let fxPosition = self.fxPosition, let fxSymbol = fxPosition.symbol {
            symbol = fxSymbol
            tradeItQuoteRequest = TradeItQuotesRequest(fxSymbol: symbol, andBroker: self.linkedBrokerAccount.brokerName)
        }

        guard (tradeItQuoteRequest != nil) else {
            onFinished()
            return
        }

        self.tradeItMarketDataService.getQuoteData(tradeItQuoteRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
            if let tradeItQuoteResult = tradeItResult as? TradeItQuotesResult {
                let results = tradeItQuoteResult.quotes?.filter { return $0.symbol == symbol }

                if let results = results as? [TradeItQuote] where results.count > 0 {
                    self.quote = results[0]
                }
            } else {
                // Should we nil this out?
                self.quote = nil
            }

            onFinished()
        })
    }
}
