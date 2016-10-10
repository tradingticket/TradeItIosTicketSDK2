import UIKit
import TradeItIosEmsApi

@objc class TradeItLauncher: NSObject {
    static var linkedBrokerManager: TradeItLinkedBrokerManager!
    var linkBrokerUIFlow: TradeItLinkBrokerUIFlow!
    var tradingUIFlow: TradeItTradingUIFlow!
    var viewControllerProvider: TradeItViewControllerProvider!
    static var marketDataService: TradeItMarketService!

    init(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        TradeItLauncher.linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
        TradeItLauncher.marketDataService = TradeItMarketService(apiKey: apiKey, environment: environment)
        self.linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
        self.tradingUIFlow = TradeItTradingUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
        self.viewControllerProvider = TradeItViewControllerProvider()
    }

    override private init() {}

    func launchPortfolio(fromViewController viewController: UIViewController) {
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { (presentedNavController: UINavigationController) -> Void in
                    let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
                    presentedNavController.setViewControllers([portfolioViewController], animated: true)
                },
                onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                    presentedNavController.topViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            )
        } else {
            let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.portfolioView)
            viewController.presentViewController(navController,
                                                 animated: true,
                                                 completion: nil)
        }
    }

    func launchTrading(fromViewController viewController: UIViewController, withOrder order: TradeItOrder = TradeItOrder()) {
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { (presentedNavController: UINavigationController) -> Void in
                    self.tradingUIFlow.pushTradingFlow(onNavigationController: presentedNavController, asRootViewController: true, withOrder: order)
                },
                onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                    presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                }
            )
        } else {
            self.tradingUIFlow.presentTradingFlow(fromViewController: viewController, withOrder: order)
        }
    }
}
