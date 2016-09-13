class FakeTradeItPortfolioPositionsTableViewManager: TradeItPortfolioPositionsTableViewManager {
    let calls = SpyRecorder()
    
    override func updatePositions(withAccount account: TradeItLinkedBrokerAccount) {
        self.calls.record(#function,
                          args: [
                            "withAccount": account,
            ])
    }
}
