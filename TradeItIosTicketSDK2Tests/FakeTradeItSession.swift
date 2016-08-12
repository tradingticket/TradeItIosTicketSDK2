class FakeTradeItSession: TradeItSession {
    let calls = SpyRecorder()

    override func authenticateAsObject(linkedLogin: TradeItLinkedLogin!, withCompletionBlock completionBlock: ((TradeItResult!) -> Void)!) {
        self.calls.record(#function, args: [
            "linkedLogin": linkedLogin,
            "withCompletionBlock": completionBlock
        ])
    }

}
