import UIKit
@testable import TradeItIosTicketSDK2

class FakeTradeItLoginViewControllerDelegate: TradeItLoginViewControllerDelegate {
    
    let calls = SpyRecorder()
    
    func brokerLinked(fromTradeItLoginViewController: TradeItLoginViewController, withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.calls.record(#function, args: [
                "fromTradeItLoginViewController": fromTradeItLoginViewController,
                "withLinkedBroker": linkedBroker
            ])
    }
}
