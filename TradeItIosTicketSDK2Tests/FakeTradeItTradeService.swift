class FakeTradeItTradeService: TradeItTradeService {
    let calls = SpyRecorder()

    override func previewTrade(previewRequest: TradeItPreviewTradeRequest!, withCompletionBlock completionBlock: ((TradeItResult!) -> Void)!) {
        self.calls.record(#function, args: [
            "previewRequest": previewRequest,
            "withCompletionBlock": completionBlock
        ])
    }
}
