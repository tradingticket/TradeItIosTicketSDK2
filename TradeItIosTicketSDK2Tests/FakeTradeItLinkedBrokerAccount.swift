@testable import TradeItIosTicketSDK2

class FakeTradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount {

    let calls = SpyRecorder()
    
    override func getAccountOverview(onSuccess: @escaping (TradeItAccountOverview) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.calls.record(#function, args: [
            "onSuccess": onSuccess,
            "onFailure": onFailure
            ])

    }
    
    override func getPositions(onSuccess: @escaping ([TradeItPortfolioPosition]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.calls.record(#function, args: [
            "onSuccess": onSuccess,
            "onFailure": onFailure
            ])
    }
}
