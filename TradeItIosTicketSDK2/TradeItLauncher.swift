import UIKit

@objc open class TradeItLauncher: NSObject {
    open static var linkedBrokerManager: TradeItLinkedBrokerManager!
    static var marketDataService: TradeItMarketService!
    var linkBrokerUIFlow: TradeItLinkBrokerUIFlow
    var tradingUIFlow: TradeItTradingUIFlow
    var viewControllerProvider: TradeItViewControllerProvider
    let deviceManager = TradeItDeviceManager()
    
    public init(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        TradeItLauncher.linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
        TradeItLauncher.marketDataService = TradeItMarketService(apiKey: apiKey, environment: environment)
        self.linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
        self.tradingUIFlow = TradeItTradingUIFlow()
        self.viewControllerProvider = TradeItViewControllerProvider()
    }

    public func launchPortfolio(fromViewController viewController: UIViewController) {
        // Show Welcome flow for users who have never linked before
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { presentedNavController, linkedBroker in
                    let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
                    presentedNavController.setViewControllers([portfolioViewController], animated: true)
                },
                onFlowAborted: { presentedNavController in
                    presentedNavController.topViewController?.dismiss(animated: true, completion: nil)
                }
            )
        } else {
            deviceManager.authenticateUserWithTouchId(
                onSuccess: {
                    print("Access granted")
                    let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.portfolioView)
                    viewController.present(navController, animated: true, completion: nil)
                },
                onFailure: {
                    print("Access denied")
                }
            )
        }
    }

    public func launchPortfolio(fromViewController viewController: UIViewController, forLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                print("Access granted")
                let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.portfolioView)
                guard let portfolioViewController = navController.viewControllers.last as? TradeItPortfolioViewController else { return }
                portfolioViewController.initialAccount = linkedBrokerAccount
                viewController.present(navController, animated: true, completion: nil)
            }, onFailure: {
                print("Access denied")
            }
        )
    }

    public func launchTrading(fromViewController viewController: UIViewController, withOrder order: TradeItOrder = TradeItOrder()) {
        // Show Welcome flow for users who have never linked before
        if (TradeItLauncher.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { presentedNavController, linkedBroker in
                    self.tradingUIFlow.pushTradingFlow(onNavigationController: presentedNavController, asRootViewController: true, withOrder: order)
                },
                onFlowAborted: { presentedNavController in
                    presentedNavController.dismiss(animated: true, completion: nil)
                }
            )
        } else {
            deviceManager.authenticateUserWithTouchId(
                onSuccess: {
                    print("Access granted")
                    self.tradingUIFlow.presentTradingFlow(fromViewController: viewController, withOrder: order)
                },
                onFailure: {
                    print("Access denied")
                }
            )
        }
    }
    
    public func launchAccountManagement(fromViewController viewController: UIViewController) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                print("Access granted")
                let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.brokerManagementView)
                viewController.present(navController, animated: true, completion: nil)
            }, onFailure: {
                print("Access denied")
            }
        )
    }

    public func launchBrokerLinking(fromViewController viewController: UIViewController, onLinked: @escaping (TradeItLinkedBroker) -> Void, onFlowAborted: @escaping () -> Void) {
        self.linkBrokerUIFlow.presentLinkBrokerFlow(fromViewController: viewController, showWelcomeScreen: false, onLinked: { presentedNavController, linkedBroker in
            presentedNavController.dismiss(animated: true, completion: nil)
            onLinked(linkedBroker)
        }, onFlowAborted: { presentedNavController in
            presentedNavController.dismiss(animated: true, completion: nil)
            onFlowAborted()
        })
    }

    public func launchBrokerCenter(fromViewController viewController: UIViewController) {
        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.brokerCenterView)
        viewController.present(navController, animated: true, completion: nil)
    }
}
