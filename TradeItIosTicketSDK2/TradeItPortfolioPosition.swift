@objc public class TradeItPortfolioPosition : NSObject {
    public var position: TradeItPosition?
    public var fxPosition: TradeItFxPosition?
    var quote: TradeItQuote?
    unowned var linkedBrokerAccount: TradeItLinkedBrokerAccount

    static let fxMaximumFractionDigits = 5

    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, position: TradeItPosition) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.position = position
    }

    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, fxPosition: TradeItFxPosition) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.fxPosition = fxPosition
    }

    func refreshQuote(onFinished: @escaping () -> Void) {
        var symbol = ""
        self.quote = nil

        if let position = self.position,  let equitySymbol = position.symbol {
            symbol = equitySymbol
        } else if let fxPosition = self.fxPosition, let fxSymbol = fxPosition.symbol {
            symbol = fxSymbol
        } else {
            onFinished()
            return
        }

        TradeItSDK.marketDataService.getQuote(symbol, onSuccess: { quote in
            self.quote = quote
            onFinished()
        }, onFailure: { errorResult in
            onFinished()
        })
    }
}
