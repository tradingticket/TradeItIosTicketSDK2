import UIKit

@objc open class TradeItLauncher: NSObject {
    open static var linkedBrokerManager: TradeItLinkedBrokerManager!
    static var marketDataService: TradeItMarketService!
    var linkBrokerUIFlow: TradeItLinkBrokerUIFlow
    var tradingUIFlow: TradeItTradingUIFlow
    var viewControllerProvider: TradeItViewControllerProvider

    public init(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        TradeItLauncher.linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
        TradeItLauncher.marketDataService = TradeItMarketService(apiKey: apiKey, environment: environment)
        self.linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
        self.tradingUIFlow = TradeItTradingUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
        self.viewControllerProvider = TradeItViewControllerProvider()
    }

    public func launchPortfolio(fromViewController viewController: UIViewController) {
        // Show Welcome flow for users who have never linked before
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                    let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
                    presentedNavController.setViewControllers([portfolioViewController], animated: true)
                },
                onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                    presentedNavController.topViewController?.dismiss(animated: true, completion: nil)
                }
            )
        } else {
            let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.portfolioView)
            viewController.present(navController, animated: true, completion: nil)
        }
    }

    public func launchTrading(fromViewController viewController: UIViewController, withOrder order: TradeItOrder = TradeItOrder()) {
        // Show Welcome flow for users who have never linked before
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                    self.tradingUIFlow.pushTradingFlow(onNavigationController: presentedNavController, asRootViewController: true, withOrder: order)
                },
                onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                    presentedNavController.dismiss(animated: true, completion: nil)
                }
            )
        } else {
            self.tradingUIFlow.presentTradingFlow(fromViewController: viewController, withOrder: order)
        }
    }
    
    public func launchAccountManagement(fromViewController viewController: UIViewController) {
        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.brokerManagementView)
        viewController.present(navController, animated: true, completion: nil)
    }

    public func launchAccountLinking(fromViewController viewController: UIViewController, onLinked: @escaping (TradeItLinkedBroker) -> Void, onFlowAborted: @escaping () -> Void) {
        self.linkBrokerUIFlow.presentLinkBrokerFlow(fromViewController: viewController, showWelcomeScreen: false, onLinked: { presentedNavController, linkedBroker in
            presentedNavController.dismiss(animated: true, completion: nil)
            onLinked(linkedBroker)
        }, onFlowAborted: { presentedNavController in
            presentedNavController.dismiss(animated: true, completion: nil)
            onFlowAborted()
        })
    }
}
