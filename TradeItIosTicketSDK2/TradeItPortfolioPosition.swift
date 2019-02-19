@objc public class TradeItPortfolioPosition : NSObject {
    @objc public var position: TradeItPosition?
    @objc public var fxPosition: TradeItFxPosition?
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
        } else if let fxPosition = self.fxPosition,
            let fxSymbol = fxPosition.symbol,
            let linkedBroker = self.linkedBrokerAccount.linkedBroker {
            linkedBroker.getFxQuote(
                symbol: fxSymbol,
                onSuccess: { quote in
                    self.quote = quote
                    onFinished()
                },
                onFailure: { _ in
                    onFinished()
                }
            )
        } else {
            onFinished()
            return
        }
    }
    
    func getProxyVoteUrl(
        onSuccess: @escaping (String?) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        guard let symbol = self.position?.symbol,
            let isProxyVoteEligible = self.position?.isProxyVoteEligible,
            isProxyVoteEligible,
            let proxyVoteService = linkedBrokerAccount.proxyVoteService else {
                let error = TradeItErrorResult(
                    title: "Fetching proxy vote url failed",
                    message: "Position is not eligible to proxy voting. Please try again."
                )
                onFailure(error)
                return
        }
        let request = TradeItGetProxyVoteUrlRequest(
            accountNumber: self.linkedBrokerAccount.accountNumber,
            symbol: symbol
        )
        
        proxyVoteService.getProxyVoteUrl(
            request,
            onSuccess: { result in
                onSuccess(result.proxyVoteUrl)
            },
            onFailure: onFailure
        )
        
    }
}
