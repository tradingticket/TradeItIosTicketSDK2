@testable import TradeItIosTicketSDK2

class FakeTradeItPositionService: TradeItPositionService {
    let calls = SpyRecorder()

    override func getAccountPositions(_ request: TradeItGetPositionsRequest!, withCompletionBlock completionBlock: ((TradeItResult?) -> Void)!) {
        self.calls.record(#function, args: [
            "request": request,
            "withCompletionBlock": completionBlock
            ])
    }
}
