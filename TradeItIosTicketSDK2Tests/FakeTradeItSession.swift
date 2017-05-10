@testable import TradeItIosTicketSDK2

class FakeTradeItSession: TradeItSession {
    let calls = SpyRecorder()

    override func authenticate(_ linkedLogin: TradeItLinkedLogin?, withCompletionBlock completionBlock: @escaping ((TradeItResult) -> Void)) {
        self.calls.record(#function, args: [
            "linkedLogin": linkedLogin,
            "withCompletionBlock": completionBlock
            ])
    }
}
