class FakeTradeItPortfolioAccountsTableViewManager: TradeItPortfolioAccountsTableViewManager {
    let calls = SpyRecorder()

    override func updateAccounts(withAccounts accounts: [TradeItAccountPortfolio]) {
        self.calls.record(#function,
                          args: [
                              "withAccounts": accounts,
                          ])
    }
}