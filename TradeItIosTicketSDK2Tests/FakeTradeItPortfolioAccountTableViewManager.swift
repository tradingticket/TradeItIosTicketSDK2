@testable import TradeItIosTicketSDK2

class FakeTradeItPortfolioAccountsTableViewManager: TradeItPortfolioAccountsTableViewManager {
    let calls = SpyRecorder()

    override func updateAccounts(withAccounts accounts: [TradeItLinkedBrokerAccount], withLinkedBrokersInError linkedBrokersInError: [TradeItLinkedBroker]) {
        self.calls.record(#function,
                          args: [
                              "withAccounts": accounts,
                              "withLinkedBrokersInError": linkedBrokersInError
                          ])
    }
}
