@objc public class TradeItLauncher: NSObject {
    let linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    let tradingUIFlow = TradeItTradingUIFlow()
    let accountSelectionUIFlow = TradeItAccountSelectionUIFlow()
    let viewControllerProvider = TradeItViewControllerProvider()
    var deviceManager = TradeItDeviceManager()

    private enum OAuthCallbackDestinationValues: String {
        case trading = "trading"
        case portfolio = "portfolio"
    }

    private enum OAuthCallbackQueryParamKeys: String {
        case oAuthVerifier = "oAuthVerifier"
        case tradeItDestination = "tradeItDestination"
//        case tradeItOrderSymbol = "tradeItOrderSymbol"
//        case tradeItOrderAction = "tradeItOrderAction"
    }

    override internal init() {}

    public func handleOAuthCallback(onViewController viewController: UIViewController, oAuthCallbackUrl: URL) {
        print("=====> LAUNCHER.handleOAuthCallback: \(oAuthCallbackUrl.absoluteString)")

        guard let urlComponents = URLComponents(url: oAuthCallbackUrl, resolvingAgainstBaseURL: false),
            let oAuthVerifier = urlComponents.queryStringValue(forKey: OAuthCallbackQueryParamKeys.oAuthVerifier.rawValue) else {
            let errorMessage = "Received invalid OAuth callback URL: \(oAuthCallbackUrl.absoluteString)"
            print("TradeItSDK ERROR: \(errorMessage)")
            TradeItAlertManager().showAlert(onViewController: viewController,
                                            withTitle: "OAuth Failed",
                                            withMessage: errorMessage,
                                            withActionTitle: "OK")
            return
        }

        TradeItSDK.linkedBrokerManager.completeOAuth(
            withOAuthVerifier: oAuthVerifier,
            onSuccess: { linkedBroker in
                print("=====> OAuth successful for \(linkedBroker.brokerName)!")
                // TODO: AUTHENTICATE BROKER HERE

                // CHECK FOR DESTINATION AND RELAUNCH
            },
            onFailure: { errorResult in
                print("TradeItSDK ERROR: OAuth failed with code: \(errorResult.errorCode()), message: \(errorResult.shortMessage) - \(errorResult.longMessages?.first)")
                TradeItAlertManager().showError(errorResult, onViewController: viewController)
            }
        )
    }
    
    public func launchPortfolio(fromViewController viewController: UIViewController) {
        // Show Welcome flow for users who have never linked before
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
            let oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl
            // TODO: Once callback is NSURL, add destination to query params
            
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                oAuthCallbackUrl: oAuthCallbackUrl
            )
        } else {
            let account = TradeItSDK.linkedBrokerManager.linkedBrokers.first?.accounts.first
            self.launchPortfolio(fromViewController: viewController, forLinkedBrokerAccount: account)
        }
    }

    public func launchPortfolio(fromViewController viewController: UIViewController,
                                forLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount?) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.portfolioView)

                guard let portfolioViewController = navController.viewControllers.last as? TradeItPortfolioViewController else { return }

                portfolioViewController.initialAccount = linkedBrokerAccount

                viewController.present(navController, animated: true, completion: nil)
            }, onFailure: {
                print("TouchId access denied")
            }
        )
    }

    public func launchPortfolio(fromViewController viewController: UIViewController, forAccountNumber accountNumber: String) {
        let accounts = TradeItSDK.linkedBrokerManager.linkedBrokers.flatMap { $0.accounts }.filter { $0.accountNumber == accountNumber }

        if accounts.isEmpty {
            print("WARNING: No linked broker accounts found matching the account number " + accountNumber)
        } else {
            if accounts.count > 1 {
                print("WARNING: there are several linked broker accounts with the same account number... taking the first one")
            }

            self.launchPortfolio(fromViewController: viewController, forLinkedBrokerAccount: accounts[0])
        }
    }

    public func launchTrading(fromViewController viewController: UIViewController,
                              withOrder order: TradeItOrder = TradeItOrder()) {
        // Show Welcome flow for users who have never linked before
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
            let oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl
            // TODO: Once callback is NSURL, add destination and order details to query params
            
            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                oAuthCallbackUrl: oAuthCallbackUrl
            )
        } else {
            deviceManager.authenticateUserWithTouchId(
                onSuccess: {
                    self.tradingUIFlow.presentTradingFlow(fromViewController: viewController, withOrder: order)
                },
                onFailure: {
                    print("TouchId access denied")
                }
            )
        }
    }

    public func launchAccountManagement(fromViewController viewController: UIViewController) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.brokerManagementView)

                viewController.present(navController, animated: true, completion: nil)
            }, onFailure: {
                print("TouchId access denied")
            }
        )
    }

    public func launchBrokerLinking(fromViewController viewController: UIViewController) {
        let showWelcomeScreen = TradeItSDK.linkedBrokerManager.linkedBrokers.count > 0
        let oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl
        // TODO: Once callback is NSURL, add destination to query params AND LAUNCH LINK SUCCESS SCREEN

        self.linkBrokerUIFlow.presentLinkBrokerFlow(fromViewController: viewController,
                                                    showWelcomeScreen: showWelcomeScreen,
                                                    oAuthCallbackUrl: oAuthCallbackUrl)
    }

    public func launchBrokerCenter(fromViewController viewController: UIViewController) {
        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.brokerCenterView)
        viewController.present(navController, animated: true, completion: nil)
    }

    public func launchAccountSelection(fromViewController viewController: UIViewController,
                                       title: String? = nil,
                                       onSelected: @escaping (TradeItLinkedBrokerAccount) -> Void) {
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
            let oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl
            // TODO: Once callback is NSURL, add destination to query params

            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                oAuthCallbackUrl: oAuthCallbackUrl
//                onLinked: { presentedNavController, linkedBroker in
//                    self.accountSelectionUIFlow.pushAccountSelectionFlow(
//                        onNavigationController: presentedNavController,
//                        title: title,
//                        onSelected: { presentedNavController, linkedBrokerAccount in
//                            presentedNavController.dismiss(animated: true, completion: nil)
//                            onSelected(linkedBrokerAccount)
//                        },
//                        onFlowAborted: { presentedNavController in
//                            presentedNavController.dismiss(animated: true, completion: nil)
//                        }
//                    )
//                }
            )
        } else {
            self.accountSelectionUIFlow.presentAccountSelectionFlow(
                fromViewController: viewController,
                title: title,
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
