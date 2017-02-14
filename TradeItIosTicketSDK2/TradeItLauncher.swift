protocol OAuthCompletionListener {
    func onOAuthCompleted(linkedBroker: TradeItLinkedBroker)
}

@objc public class TradeItLauncher: NSObject {
    let linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    let tradingUIFlow = TradeItTradingUIFlow()
    let accountSelectionUIFlow = TradeItAccountSelectionUIFlow()
    let viewControllerProvider = TradeItViewControllerProvider()
    let deviceManager = TradeItDeviceManager()
    let alertManager = TradeItAlertManager()

    private enum OAuthCallbackDestinationValues: String {
        case trading = "trading"
        case portfolio = "portfolio"
    }

    private enum OAuthCallbackQueryParamKeys: String {
        case oAuthVerifier = "oAuthVerifier"
        case tradeItDestination = "tradeItDestination"
        case tradeItOrderSymbol = "tradeItOrderSymbol"
        case tradeItOrderAction = "tradeItOrderAction"
    }

    override internal init() {}

    public func handleOAuthCallback(onViewController viewController: UIViewController, oAuthCallbackUrl: URL) {
        print("=====> LAUNCHER.handleOAuthCallback: \(oAuthCallbackUrl.absoluteString)")

        guard let urlComponents = URLComponents(url: oAuthCallbackUrl, resolvingAgainstBaseURL: false),
            let oAuthVerifier = urlComponents.queryStringValue(forKey: OAuthCallbackQueryParamKeys.oAuthVerifier.rawValue) else {
            let errorMessage = "Received invalid OAuth callback URL: \(oAuthCallbackUrl.absoluteString)"
            print("TradeItSDK ERROR: \(errorMessage)")
            self.alertManager.showAlert(onViewController: viewController,
                                            withTitle: "OAuth Failed",
                                            withMessage: errorMessage,
                                            withActionTitle: "OK")
            return
        }

        TradeItSDK.linkedBrokerManager.completeOAuth(
            withOAuthVerifier: oAuthVerifier,
            onSuccess: { linkedBroker in
                linkedBroker.authenticateIfNeeded(
                    onSuccess: {
                        if let oAuthCompletionListener = viewController as? OAuthCompletionListener {
                            oAuthCompletionListener.onOAuthCompleted(linkedBroker: linkedBroker)
                        }

                        self.launchOAuthDestination(onViewController: viewController, urlComponents: urlComponents)
                    },
                    onSecurityQuestion: { (securityQuestion, answerSecurityQuestion, cancelSecurityQuestion) in
                        self.alertManager.promptUserToAnswerSecurityQuestion(
                            securityQuestion,
                            onViewController: viewController,
                            onAnswerSecurityQuestion: answerSecurityQuestion,
                            onCancelSecurityQuestion: cancelSecurityQuestion
                        )

                    },
                    onFailure: { errorResult in
                        self.alertManager.showRelinkError(
                            errorResult,
                            withLinkedBroker: linkedBroker,
                            onViewController: viewController,
                            onFinished : {
                                if let oAuthCompletionListener = viewController as? OAuthCompletionListener {
                                    oAuthCompletionListener.onOAuthCompleted(linkedBroker: linkedBroker)
                                }

                                self.launchOAuthDestination(onViewController: viewController, urlComponents: urlComponents)
                            }
                        )
                    }
                )
            },
            onFailure: { errorResult in
                print("TradeItSDK ERROR: OAuth failed with code: \(errorResult.errorCode()), message: \(errorResult.shortMessage) - \(errorResult.longMessages?.first)")
                self.alertManager.showError(errorResult, onViewController: viewController)
            }
        )
    }

    private func launchOAuthDestination(onViewController viewController: UIViewController,
                                        urlComponents: URLComponents) {
        if let destinationString = urlComponents.queryStringValue(forKey: OAuthCallbackQueryParamKeys.tradeItDestination.rawValue),
            let destination = OAuthCallbackDestinationValues(rawValue: destinationString) {

            switch destination {
            case .portfolio:
                TradeItSDK.launcher.launchPortfolio(fromViewController: viewController)
            case .trading:
                let symbol = urlComponents.queryStringValue(forKey: OAuthCallbackQueryParamKeys.tradeItOrderSymbol.rawValue)
                var action = TradeItOrderActionPresenter.DEFAULT

                if let actionString = urlComponents.queryStringValue(forKey: OAuthCallbackQueryParamKeys.tradeItOrderSymbol.rawValue) {
                    let actionFromQueryString = TradeItOrderActionPresenter.enumFor(actionString)
                    if actionFromQueryString != .unknown {
                        action = actionFromQueryString
                    }
                }

                let order = TradeItOrder(symbol: symbol, action: action)

                TradeItSDK.launcher.launchTrading(fromViewController: viewController,
                                                  withOrder: order)
            }
        }

    }

    public func launchPortfolio(fromViewController viewController: UIViewController) {
        // Show Welcome flow for users who have never linked before
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
            var oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl

            if var urlComponents = URLComponents(url: oAuthCallbackUrl,
                                                 resolvingAgainstBaseURL: false) {
                urlComponents.addOrUpdateQueryStringValue(
                    forKey: OAuthCallbackQueryParamKeys.tradeItDestination.rawValue,
                    value: OAuthCallbackDestinationValues.portfolio.rawValue)

                oAuthCallbackUrl = urlComponents.url ?? oAuthCallbackUrl
            }
            
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
            var oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl

            if var urlComponents = URLComponents(url: oAuthCallbackUrl,
                                                 resolvingAgainstBaseURL: false) {
                urlComponents.addOrUpdateQueryStringValue(
                    forKey: OAuthCallbackQueryParamKeys.tradeItDestination.rawValue,
                    value: OAuthCallbackDestinationValues.trading.rawValue)

                urlComponents.addOrUpdateQueryStringValue(
                    forKey: OAuthCallbackQueryParamKeys.tradeItOrderSymbol.rawValue,
                    value: order.symbol)

                if order.action != .unknown {
                    urlComponents.addOrUpdateQueryStringValue(
                        forKey: OAuthCallbackQueryParamKeys.tradeItOrderAction.rawValue,
                        value: TradeItOrderActionPresenter.labelFor(order.action))
                }

                oAuthCallbackUrl = urlComponents.url ?? oAuthCallbackUrl
            }

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
