import UIKit
import SafariServices

protocol OAuthCompletionListener {
    func onOAuthCompleted(linkedBroker: TradeItLinkedBroker)
}

@objc public class TradeItLauncher: NSObject {
    let linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    let tradingUIFlow = TradeItTradingUIFlow()
    let accountSelectionUIFlow = TradeItAccountSelectionUIFlow()
    let oAuthCompletionUIFlow = TradeItOAuthCompletionUIFlow()
    let viewControllerProvider = TradeItViewControllerProvider()
    var deviceManager = TradeItDeviceManager()
    let alertManager = TradeItAlertManager()

    static var accountSelectionCallback: ((TradeItLinkedBrokerAccount) -> Void)? // Ew, gross. No other way to do this.
    static var accountSelectionTitle: String? // Ew, gross. No other way to do this.

    override internal init() {}

    public func handleOAuthCallback(
        onTopmostViewController topMostViewController: UIViewController,
        oAuthCallbackUrl: URL
    ) {
        print("=====> handleOAuthCallback: \(oAuthCallbackUrl.absoluteString)")

        let oAuthCallbackUrlParser = TradeItOAuthCallbackUrlParser(oAuthCallbackUrl: oAuthCallbackUrl)

        var originalViewController: UIViewController?

        // Check for the OAuth "popup" screen
        if topMostViewController is SFSafariViewController {
            originalViewController = topMostViewController.presentingViewController
        }

        // Check for the broker selection screen
        if originalViewController?.childViewControllers.first is TradeItSelectBrokerViewController {
            originalViewController = originalViewController?.presentingViewController
        }

        // If either the OAuth "popup" or broker selection screens are present, dismiss them before presenting
        // the OAuth completion screen
        if let originalViewController = originalViewController {
            originalViewController.dismiss(
                animated: true,
                completion: {
                    self.oAuthCompletionUIFlow.presentOAuthCompletionFlow(
                        fromViewController: originalViewController,
                        oAuthCallbackUrlParser: oAuthCallbackUrlParser
                    )
                }
            )
        } else {
            self.oAuthCompletionUIFlow.presentOAuthCompletionFlow(
                fromViewController: topMostViewController,
                oAuthCallbackUrlParser: oAuthCallbackUrlParser
            )
        }
    }

    public func launchPortfolio(fromViewController viewController: UIViewController) {
        // If user has no linked brokers, set OAuth callback destination and show welcome flow instead
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
            var oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl

            if var urlComponents = URLComponents(
                url: oAuthCallbackUrl,
                resolvingAgainstBaseURL: false
            ) {
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
            deviceManager.authenticateUserWithTouchId(
                onSuccess: {
                    let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .portfolioAccountsView)
                    viewController.present(navController, animated: true, completion: nil)
                }, onFailure: {
                    print("TouchId access denied")
                }
            )
        }
    }

    public func launchPortfolio(
        fromViewController viewController: UIViewController,
        forLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount?
    ) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .portfolioAccountDetailsView)

                guard let portfolioAccountDetailsViewController = navController.viewControllers.last as? TradeItPortfolioAccountDetailsViewController else { return }

                portfolioAccountDetailsViewController.automaticallyAdjustsScrollViewInsets = true
                portfolioAccountDetailsViewController.linkedBrokerAccount = linkedBrokerAccount

                viewController.present(navController, animated: true, completion: nil)
            }, onFailure: {
                print("TouchId access denied")
            }
        )
    }

    public func launchPortfolio(
        fromViewController viewController: UIViewController,
        forAccountNumber accountNumber: String
    ) {
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

    public func launchTrading(
        fromViewController viewController: UIViewController,
        withOrder order: TradeItOrder = TradeItOrder()
    ) {
        // If user has no linked brokers, set OAuth callback destination and show welcome flow instead
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
            },
            onFailure: {
                print("TouchId access denied")
            }
        )
    }

    public func launchBrokerLinking(fromViewController viewController: UIViewController) {
        let showWelcomeScreen = TradeItSDK.linkedBrokerManager.linkedBrokers.count > 0
        let oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl

        self.linkBrokerUIFlow.presentLinkBrokerFlow(
            fromViewController: viewController,
            showWelcomeScreen: showWelcomeScreen,
            oAuthCallbackUrl: oAuthCallbackUrl
        )
    }

    public func launchBrokerCenter(fromViewController viewController: UIViewController) {
        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.webView)

        guard let webViewController = navController.viewControllers.last as? TradeItWebViewController else { return }
        webViewController.pageTitle = "Broker Center"
        webViewController.url = TradeItSDK.brokerCenterService.getUrl()

        viewController.present(navController, animated: true, completion: nil)

    }

    public func launchAccountSelection(
        fromViewController viewController: UIViewController,
        title: String? = nil,
        onSelected: @escaping (TradeItLinkedBrokerAccount) -> Void
    ) {
        if (TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0) {
            var oAuthCallbackUrl = TradeItSDK.oAuthCallbackUrl

            if var urlComponents = URLComponents(
                url: oAuthCallbackUrl,
                resolvingAgainstBaseURL: false
            ) {
                urlComponents.addOrUpdateQueryStringValue(
                    forKey: OAuthCallbackQueryParamKeys.tradeItDestination.rawValue,
                    value: OAuthCallbackDestinationValues.accountSelection.rawValue
                )

                oAuthCallbackUrl = urlComponents.url ?? oAuthCallbackUrl
            }

            TradeItLauncher.accountSelectionCallback = onSelected
            TradeItLauncher.accountSelectionTitle = title

            self.linkBrokerUIFlow.presentLinkBrokerFlow(
                fromViewController: viewController,
                showWelcomeScreen: true,
                oAuthCallbackUrl: oAuthCallbackUrl
            )
        } else {
            self.accountSelectionUIFlow.presentAccountSelectionFlow(
                fromViewController: viewController,
                title: title,
                onSelected: { presentedNavController, linkedBrokerAccount in
                    presentedNavController.dismiss(animated: true, completion: nil)
                    onSelected(linkedBrokerAccount)
                }
            )
        }
    }
}
