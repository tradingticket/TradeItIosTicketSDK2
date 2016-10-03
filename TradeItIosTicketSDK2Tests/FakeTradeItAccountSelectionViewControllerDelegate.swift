import UIKit

class FakeTradeItAccountSelectionViewControllerDelegate: TradeItAccountSelectionViewControllerDelegate {

    let calls = SpyRecorder()
    
    func linkedBrokerAccountWasSelected(fromAccountSelectionViewController: TradeItAccountSelectionViewController, linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.calls.record(#function, args: [
            "fromAccountSelectionViewController": fromAccountSelectionViewController,
            "linkedBrokerAccount": linkedBrokerAccount
            ])
    }

}
