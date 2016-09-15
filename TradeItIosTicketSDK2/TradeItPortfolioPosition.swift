import TradeItIosEmsApi

class TradeItPortfolioPosition : NSObject {
    var position: TradeItPosition!
    var fxPosition: TradeItFxPosition!
    var quote: TradeItQuote!
    var tradeItMarketDataService: TradeItMarketDataService!
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
        var tradeItQuoteRequest: TradeItQuotesRequest!
        var symbol = ""
        if let position = self.position {
            symbol = position.symbol
            tradeItQuoteRequest = TradeItQuotesRequest(symbol: symbol)
        }
        if let fxPosition = self.fxPosition {
                symbol = fxPosition.symbol
                tradeItQuoteRequest = TradeItQuotesRequest(fxSymbol: symbol, andBroker: self.linkedBrokerAccount.brokerName)
        }
        var quote = TradeItQuote()
        self.tradeItMarketDataService.getQuoteData(tradeItQuoteRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
            if let tradeItQuoteResult = tradeItResult as? TradeItQuotesResult {
                let results = tradeItQuoteResult.quotes.filter { return $0.symbol == symbol}
                if results.count > 0 {
                    quote = results[0] as! TradeItQuote
                    self.quote = quote
                }
            }
            else {
                //TODO handle error
                print("error quote")
            }
            onFinished()
        })
    }
}
