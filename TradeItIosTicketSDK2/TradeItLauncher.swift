import UIKit
import TradeItIosEmsApi

@objc class TradeItLauncher: NSObject {
    static var linkedBrokerManager: TradeItLinkedBrokerManager!
    var linkBrokerUIFlow: TradeItLinkBrokerUIFlow!
    var viewControllerProvider: TradeItViewControllerProvider!
    static var marketDataService: TradeItMarketService!

    init(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        let tradeItConnector = TradeItConnector(apiKey: apiKey)!
        tradeItConnector.environment = environment
        TradeItLauncher.linkedBrokerManager = TradeItLinkedBrokerManager(connector: tradeItConnector)
        TradeItLauncher.marketDataService = TradeItMarketService(connector: tradeItConnector)
        self.linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
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

    func launchTrading(fromViewController viewController: UIViewController, withOrder order: TradeItOrder) {
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { (presentedNavController: UINavigationController) -> Void in
                    guard let tradingTicketViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.tradingTicketView) as? TradeItTradingTicketViewController else {
                        presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                        return
                    }

                    tradingTicketViewController.order = order
                    presentedNavController.setViewControllers([tradingTicketViewController], animated: true)
                },
                onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                    presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                }
            )
        } else {
            let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.tradingTicketView)
            guard let tradingTicketViewController = navController.topViewController as? TradeItTradingTicketViewController else { return }

            tradingTicketViewController.order = order

            viewController.presentViewController(navController,
                                                 animated: true,
                                                 completion: nil)
        }
    }
}
