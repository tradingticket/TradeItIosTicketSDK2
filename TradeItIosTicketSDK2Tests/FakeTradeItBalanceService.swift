class FakeTradeItBalanceService: TradeItBalanceService {
    let calls = SpyRecorder()
    
    override func getAccountOverview(request: TradeItAccountOverviewRequest!, withCompletionBlock completionBlock: ((TradeItResult!) -> Void)!) {
        self.calls.record(#function, args: [
            "request": request,
            "withCompletionBlock": completionBlock
            ])
    }
}
