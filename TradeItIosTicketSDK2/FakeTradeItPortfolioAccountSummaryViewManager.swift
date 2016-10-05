
class FakeTradeItPortfolioAccountSummaryViewManager: TradeItPortfolioAccountSummaryViewManager {
    let calls = SpyRecorder()
    override func populateSummarySection(selectedAccount: TradeItLinkedBrokerAccount) {
        calls.record(#function, args: [
            "selectedAccount": selectedAccount
            ])
    }
}
