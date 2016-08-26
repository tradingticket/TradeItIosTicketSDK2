import TradeItIosEmsApi

class FakeTradeItSession: TradeItSession {
    let calls = SpyRecorder()

    override func authenticate(linkedLogin: TradeItLinkedLogin!, withObjectsCompletionBlock completionBlock: ((TradeItResult!) -> Void)!) {
        self.calls.record(#function, args: [
                "linkedLogin": linkedLogin,
                "withCompletionBlock": completionBlock
            ])
    }
}