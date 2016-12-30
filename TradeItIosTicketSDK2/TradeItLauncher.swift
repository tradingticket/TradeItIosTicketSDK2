@objc public class TradeItLauncher: NSObject {
    let linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    let tradingUIFlow = TradeItTradingUIFlow()
    let accountSelectionUIFlow = TradeItAccountSelectionUIFlow()
    let viewControllerProvider = TradeItViewControllerProvider()
    var deviceManager = TradeItDeviceManager()

    override internal init() {}

    public func launchPortfolio(fromViewController viewController: UIViewController) {
        // Show Welcome flow for users who have never linked before
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
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

    public func launchPortfolio(fromViewController viewController: UIViewController, forAccountNumber accountNumber: String) {
        let accounts = TradeItSDK.linkedBrokerManager.linkedBrokers.flatMap { $0.accounts }.filter { $0.accountNumber == accountNumber }
        if accounts.isEmpty {
            print("No linked broker accounts found matching the account number " + accountNumber)
        } else {
            if accounts.count > 1 {
                print("WARNING: there are several linked broker accounts with the same account number... taking the first one")
            }
            self.launchPortfolio(fromViewController: viewController, forLinkedBrokerAccount: accounts[0])
        }
    }

    public func launchTrading(fromViewController viewController: UIViewController, withOrder order: TradeItOrder = TradeItOrder()) {
        // Show Welcome flow for users who have never linked before
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
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

    public func launchAccountSelection(fromViewController viewController: UIViewController, onSelected: @escaping (TradeItLinkedBrokerAccount) -> Void) {
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                onLinked: { presentedNavController, linkedBroker in
                    self.accountSelectionUIFlow.pushAccountSelectionFlow(
                        onNavigationController: presentedNavController,
                        onSelected: { presentedNavController, linkedBrokerAccount in
                            presentedNavController.dismiss(animated: true, completion: nil)
                            onSelected(linkedBrokerAccount)
                        },
                        onFlowAborted: { presentedNavController in
                            presentedNavController.dismiss(animated: true, completion: nil)
                        }
                    )
                },
                onFlowAborted: { presentedNavController in
                    presentedNavController.dismiss(animated: true, completion: nil)
                }
            )
        } else {
            self.accountSelectionUIFlow.presentAccountSelectionFlow(
                fromViewController: viewController,
                onSelected: { presentedNavController, linkedBrokerAccount in
                    presentedNavController.dismiss(animated: true, completion: nil)
                    onSelected(linkedBrokerAccount)
                },
                onFlowAborted: { presentedNavController in
                    presentedNavController.dismiss(animated: true, completion: nil)
                }
            )
        }
    }
}
