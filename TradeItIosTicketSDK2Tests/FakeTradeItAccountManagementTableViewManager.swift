import UIKit
@testable import TradeItIosTicketSDK2

class FakeTradeItAccountManagementTableViewManager: TradeItAccountManagementTableViewManager {
    let calls = SpyRecorder()
    
    override func updateAccounts(withAccounts linkedBrokerAccounts: [TradeItLinkedBrokerAccount]) {
        self.calls.record(#function,
                          args: [
                            "withAccounts": linkedBrokerAccounts,
            ])
    }
}
