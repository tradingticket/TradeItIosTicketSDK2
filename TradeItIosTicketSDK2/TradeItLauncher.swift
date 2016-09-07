import UIKit
import TradeItIosEmsApi

@objc class TradeItLauncher: NSObject {
    static var linkedBrokerManager: TradeItLinkedBrokerManager!

    init(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        let tradeItConnector = TradeItConnector(apiKey: apiKey)!
        tradeItConnector.environment = environment
        TradeItLauncher.linkedBrokerManager = TradeItLinkedBrokerManager(connector: tradeItConnector)
    }

    override private init() {}

    func launchTradeIt(fromViewController viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2"))

        guard let navigationViewController = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_NAV_VIEW") as?UINavigationController else {
            return
        }

        viewController.presentViewController(navigationViewController, animated: true, completion: nil)
    }
}