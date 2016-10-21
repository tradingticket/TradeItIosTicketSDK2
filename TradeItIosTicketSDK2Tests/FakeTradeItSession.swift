@testable import TradeItIosTicketSDK2

class FakeTradeItSession: TradeItSession {
    let calls = SpyRecorder()

    override func authenticate(linkedLogin: TradeItLinkedLogin!, withCompletionBlock completionBlock: ((TradeItResult!) -> Void)!) {
        self.calls.record(#function, args: [
            "linkedLogin": linkedLogin,
            "withCompletionBlock": completionBlock
            ])
    }
}
