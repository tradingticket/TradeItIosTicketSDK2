import UIKit
import TradeItIosEmsApi

@objc class TradeItLauncher: NSObject {
    static var linkedBrokerManager: TradeItLinkedBrokerManager!
    var linkBrokerUIFlow: TradeItLinkBrokerUIFlow!
    var viewControllerProvider: TradeItViewControllerProvider!

    init(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        let tradeItConnector = TradeItConnector(apiKey: apiKey)!
        tradeItConnector.environment = environment
        TradeItLauncher.linkedBrokerManager = TradeItLinkedBrokerManager(connector: tradeItConnector)

        self.linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
        self.viewControllerProvider = TradeItViewControllerProvider()
    }

    override private init() {}

    func launchPortfolio(fromViewController viewController: UIViewController) {
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.portfolioView)
            navController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

            self.linkBrokerUIFlow.launchLinkBrokerFlow(
                inViewController: viewController,
                showWelcomeScreen: true,
                promptForAccountSelection: false,
                onLinked: { (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void in
                    let portfolioViewController = self.viewControllerProvider.provideViewController(withStoryboardId: TradeItStoryboardID.portfolioView)
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
}
