import UIKit
import TradeItIosEmsApi

class FakeTradeItLinkBrokerUIFlow: TradeItLinkBrokerUIFlow {
    
    let calls = SpyRecorder()
    
    override func launchIntoLoginScreen(inViewController viewController: UIViewController, selectedBroker: TradeItBroker, selectedReLinkedBroker: TradeItLinkedBroker, mode: TradeItLoginViewControllerMode, onLinked: (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void, onFlowAborted: (presentedNavController: UINavigationController) -> Void) {
        self.calls.record(#function, args: [
            "inViewController": viewController,
            "selectedBroker": selectedBroker ,
            "selectedRelinkedBroker": selectedReLinkedBroker ,
            "mode": mode ,
            "onLinked": onLinked ,
            "onFlowAborted": onFlowAborted
            ])
    }
}
