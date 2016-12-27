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
        if let position = self.position, let equitySymbol = position.symbol {
            TradeItSDK.marketDataService.getQuote(symbol: equitySymbol, onSuccess: { quote in
                self.quote = quote
                onFinished()
            }, onFailure: { _ in
                onFinished()
            })
        } else if let fxPosition = self.fxPosition, let fxSymbol = fxPosition.symbol {
            let broker = self.linkedBrokerAccount.brokerName
            TradeItSDK.marketDataService.getFxQuote(symbol: fxSymbol, broker: broker, onSuccess: { quote in
                self.quote = quote
                onFinished()
            }, onFailure: { _ in
                onFinished()
            })
        } else {
            onFinished()
            return
        }
    }
}
