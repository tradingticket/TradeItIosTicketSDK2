@testable import TradeItIosTicketSDK2

class FakeTradeItBalanceService: TradeItBalanceService {
    let calls = SpyRecorder()
    
    override func getAccountOverview(_ request: TradeItAccountOverviewRequest!, withCompletionBlock completionBlock: ((TradeItResult?) -> Void)!) {
        self.calls.record(#function, args: [
            "request": request,
            "withCompletionBlock": completionBlock
            ])
    }
}
