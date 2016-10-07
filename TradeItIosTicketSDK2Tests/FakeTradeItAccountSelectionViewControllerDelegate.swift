import UIKit

class FakeTradeItAccountSelectionViewControllerDelegate: TradeItAccountSelectionViewControllerDelegate {

    let calls = SpyRecorder()
    
    func accountSelectionViewController(accountSelectionViewController: TradeItAccountSelectionViewController, didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.calls.record(#function,
                          args: [
                            "accountSelectionViewController": accountSelectionViewController,
                            "didSelectLinkedBrokerAccount": linkedBrokerAccount
                          ])
    }
    
    func accountSelectionCancelled(forAccountSelectionViewController accountSelectionViewController: TradeItAccountSelectionViewController) {
        self.calls.record(#function,
                          args: [
                            "accountSelectionViewController": accountSelectionViewController
            ])
    }

}
