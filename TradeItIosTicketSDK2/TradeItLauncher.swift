import UIKit

@objc class TradeItLauncher: NSObject {
    static var tradeItConnector: TradeItConnector! = nil

    init(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        TradeItLauncher.tradeItConnector = TradeItConnector(apiKey: apiKey)
        TradeItLauncher.tradeItConnector.environment = environment
    }

    override private init() {}

    func launchTradeItFromViewController(viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2") )
        let navigationViewController = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_NAV_VIEW")
        viewController.presentViewController(navigationViewController, animated: true, completion: nil)
    }
}