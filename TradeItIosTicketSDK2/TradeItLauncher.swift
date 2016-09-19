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

        viewController.presentViewController(loadNavigationViewController(), animated: true, completion: nil)
    }

    func loadNavigationViewController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: TradeItBundleProvider.provide())

        guard let navigationViewController = storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.navView.rawValue) as? UINavigationController else {
            return UINavigationController()
        }
        let rootViewController = selectRootViewController(storyboard)
        navigationViewController.setViewControllers([rootViewController], animated: false)
        return navigationViewController
    }

    func selectRootViewController(storyboard: UIStoryboard) -> UIViewController {
        let rootViewController: UIViewController?
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count > 0) {
            rootViewController = storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.portfolioView.rawValue)
        } else {
            rootViewController =  storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.welcomeView.rawValue)
        }

        return rootViewController ?? UIViewController()
    }
}
