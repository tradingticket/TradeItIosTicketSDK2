import UIKit
@testable import TradeItIosTicketSDK2

class FakeTradeItLinkBrokerUIFlow: TradeItLinkBrokerUIFlow {
    
    let calls = SpyRecorder()
//    override func presentRelinkBrokerFlow(inViewController viewController: UIViewController, linkedBroker: TradeItLinkedBroker, onLinked: @escaping (_ presentedNavController: UINavigationController, _ linkedBroker: TradeItLinkedBroker) -> Void, onFlowAborted: @escaping (_ presentedNavController: UINavigationController) -> Void) {
//        self.calls.record(#function,
//                          args: [
//                            "inViewController": viewController,
//                            "linkedBroker": linkedBroker,
//                            "onLinked": onLinked,
//                            "onFlowAborted": onFlowAborted
//            ])
//    }
}
