@testable import TradeItIosTicketSDK2

class FakeTradeItTradeService: TradeItEquityTradeService {
    let calls = SpyRecorder()

    override func previewTrade(_ previewRequest: TradeItPreviewTradeRequest!, withCompletionBlock completionBlock: ((TradeItResult?) -> Void)!) {
        self.calls.record(#function, args: [
            "previewRequest": previewRequest,
            "withCompletionBlock": completionBlock
        ])
    }
}
