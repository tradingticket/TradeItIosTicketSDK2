class FakeTradeItPortfolioAccountsTableViewManager: TradeItPortfolioAccountsTableViewManager {
    let calls = SpyRecorder()

    override func updateAccounts(withAccounts accounts: [TradeItLinkedBrokerAccount]) {
        self.calls.record(#function,
                          args: [
                              "withAccounts": accounts,
                          ])
    }
}