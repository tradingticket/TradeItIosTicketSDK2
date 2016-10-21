@testable import TradeItIosTicketSDK2

class FakeTradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount {

    let calls = SpyRecorder()
    
    override func getAccountOverview(onSuccess onSuccess: () -> Void, onFailure: (TradeItErrorResult) -> Void) {
        self.calls.record(#function, args: [
            "onSuccess": onSuccess,
            "onFailure": onFailure
            ])

    }
    
    override func getPositions(onSuccess onSuccess: () -> Void, onFailure: (TradeItErrorResult) -> Void) {
        self.calls.record(#function, args: [
            "onSuccess": onSuccess,
            "onFailure": onFailure
            ])
    }
}
