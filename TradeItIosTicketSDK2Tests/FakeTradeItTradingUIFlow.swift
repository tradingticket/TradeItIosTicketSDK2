import UIKit
@testable import TradeItIosTicketSDK2

class FakeTradeItTradingUIFlow: TradeItTradingUIFlow {
    
    let calls = SpyRecorder()
    
    override func presentTradingFlow(fromViewController viewController: UIViewController, withOrder order: TradeItOrder) {
        self.calls.record(#function, args: [
                "viewController": viewController,
                "order": order
            ])
    }
    
    override func pushTradingFlow(onNavigationController navController: UINavigationController, asRootViewController: Bool, withOrder order: TradeItOrder) {
        self.calls.record(#function, args: [
                "navController": navController,
                "asRootViewController": asRootViewController,
                "order": order
            ])
    }
    
}
