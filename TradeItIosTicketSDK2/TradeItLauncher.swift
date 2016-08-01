import UIKit

@objc class TradeItLauncher: NSObject {
    func launchTradeItFromViewController(viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2") )
        let navigationViewController = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_NAV_VIEW")
        viewController.presentViewController(navigationViewController, animated: true, completion: nil)
    }
}