import UIKit
import TradeItIosEmsApi

class FakeTradeItLinkBrokerUIFlow: TradeItLinkBrokerUIFlow {
    
    let calls = SpyRecorder()
    
    override func launchRelinkBrokerFlow(inViewController viewController: UIViewController,
                                                          linkedBroker: TradeItLinkedBroker,
                                                          onLinked: (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void,
                                                          onFlowAborted: (presentedNavController: UINavigationController) -> Void) {
        self.calls.record(#function,
                          args: [
                            "inViewController": viewController,
                            "linkedBroker": linkedBroker,
                            "onLinked": onLinked,
                            "onFlowAborted": onFlowAborted
                          ])
    }
}
