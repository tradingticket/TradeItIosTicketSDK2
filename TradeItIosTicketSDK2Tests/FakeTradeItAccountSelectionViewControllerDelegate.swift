@testable import TradeItIosTicketSDK2

class FakeTradeItAccountSelectionViewControllerDelegate: TradeItAccountSelectionViewControllerDelegate {

    let calls = SpyRecorder()
    
    func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController, didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.calls.record(#function,
                          args: [
                            "accountSelectionViewController": accountSelectionViewController,
                            "didSelectLinkedBrokerAccount": linkedBrokerAccount
                          ])
    }
}
