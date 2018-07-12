import UIKit
import SafariServices

@objc public protocol YahooLauncherDelegate {

    func yahooLauncherDidSelectLearnMore(
        fromViewController viewController: UIViewController
    )
}

@objc public class TradeItYahooLauncher: NSObject {
    private let yahooViewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    private let tradeItViewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeIt")
    private var deviceManager = TradeItDeviceManager()
    private let equityTradingUIFlow = TradeItYahooEquityTradingUIFlow()
    private let cryptoTradingUIFlow = TradeItYahooCryptoTradingUIFlow()
    private let oAuthCompletionUIFlow = TradeItYahooOAuthCompletionUIFlow()
    private let linkBrokerUIFlow = TradeItYahooLinkBrokerUIFlow()
    private let alertManager = TradeItAlertManager()

    weak var delegate: YahooLauncherDelegate?

    override internal init() {
        TradeItSDK.uiConfigService.isEnabled = false
    }
    
    @objc public func launchOAuth(fromViewController viewController: UIViewController) {
        self.launchOAuth(
            fromViewController: viewController,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl,
            delegate: nil
        )
    }

    @objc public func launchOAuth(
        fromViewController viewController: UIViewController,
        oAuthCallbackUrl: URL,
        delegate: YahooLauncherDelegate?
    ) {
        self.linkBrokerUIFlow.presentLinkBrokerFlow(
            fromViewController: viewController,
            showWelcomeScreen: false,
            oAuthCallbackUrl: oAuthCallbackUrl,
            delegate: delegate
        )
    }

    @objc public func launchRelinking(
        fromViewController viewController: UIViewController,
        forLinkedBroker linkedBroker: TradeItLinkedBroker
    ) {
        self.launchRelinking(
            fromViewController: viewController,
            forLinkedBroker: linkedBroker,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl
        )
    }

    @objc public func launchRelinking(
        fromViewController viewController: UIViewController,
        forLinkedBroker linkedBroker: TradeItLinkedBroker,
        oAuthCallbackUrl: URL
    ) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: viewController,
            linkedBroker: linkedBroker,
            oAuthCallbackUrl: oAuthCallbackUrl
        )
    }

    @objc public func handleOAuthCallback(
        onTopmostViewController topMostViewController: UIViewController,
        oAuthCallbackUrl: URL,
        onOAuthCompletionSuccessHandler: OnOAuthCompletionSuccessHandler? = nil
    ) {
        print("=====> handleOAuthCallback: \(oAuthCallbackUrl.absoluteString)")

        let oAuthCallbackUrlParser = TradeItOAuthCallbackUrlParser(oAuthCallbackUrl: oAuthCallbackUrl)

        var originalViewController: UIViewController?

        // Check for the OAuth "popup" screen
        if topMostViewController is SFSafariViewController {
            originalViewController = topMostViewController.presentingViewController
        }

        // Check for the broker selection screen
        if originalViewController?.childViewControllers.first is TradeItYahooBrokerSelectionViewController {
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
                        oAuthCallbackUrlParser: oAuthCallbackUrlParser,
                        onOAuthCompletionSuccessHandler: onOAuthCompletionSuccessHandler
                    )
                }
            )
        } else {
            self.oAuthCompletionUIFlow.presentOAuthCompletionFlow(
                fromViewController: topMostViewController,
                oAuthCallbackUrlParser: oAuthCallbackUrlParser,
                onOAuthCompletionSuccessHandler: onOAuthCompletionSuccessHandler
            )
        }
    }

    @objc public func launchTrading(
        fromViewController viewController: UIViewController,
        withOrder order: TradeItOrder,
        onViewPortfolioTappedHandler: @escaping OnViewPortfolioTappedHandler
    ) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                print("Access granted")
                self.equityTradingUIFlow.presentTradingFlow(
                    fromViewController: viewController,
                    withOrder: order,
                    onViewPortfolioTappedHandler: onViewPortfolioTappedHandler
                )
            },
            onFailure: {
                print("Access denied")
            }
        )
    }

    @objc public func launchCryptoTrading(
        fromViewController viewController: UIViewController,
        withOrder order: TradeItCryptoOrder,
        onViewPortfolioTappedHandler: @escaping OnViewPortfolioTappedHandler
    ) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                print("Access granted")
                self.cryptoTradingUIFlow.presentTradingFlow(
                    fromViewController: viewController,
                    withOrder: order,
                    onViewPortfolioTappedHandler: onViewPortfolioTappedHandler
                )
            },
            onFailure: {
                print("Access denied")
            }
        )
    }
    
    @objc public func launchAuthentication(
        forLinkedBroker linkedBroker: TradeItLinkedBroker,
        onViewController viewController: UIViewController,
        onCompletion: @escaping () -> Void
    ) {
        linkedBroker.authenticate(
            onSuccess: { onCompletion() },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: viewController,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelQuestion)
            },
            onFailure: { errorResult in
                self.alertManager.showAlertWithAction(
                    error: errorResult,
                    withLinkedBroker: linkedBroker,
                    onViewController: viewController,
                    onFinished: {
                        onCompletion()
                    }
                )
            }
        )
    }

    @objc public func launchOrders(
        fromViewController viewController: UIViewController,
        forLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount
    ) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                let navController = TradeItYahooNavigationController()
                guard let ordersViewController = self.tradeItViewControllerProvider.provideViewController(forStoryboardId: .ordersView) as? TradeItOrdersViewController else { return }
                ordersViewController.enableThemeOnLoad = false
                ordersViewController.enableCustomNavController()
                ordersViewController.linkedBrokerAccount = linkedBrokerAccount
                navController.pushViewController(ordersViewController, animated: false)
                viewController.present(navController, animated: true, completion: nil)
            }, onFailure: {
                print("TouchId access denied")
            }
        )
    }

    @objc public func launchTransactions(
        fromViewController viewController: UIViewController,
        forLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount
    ) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                let navController = TradeItYahooNavigationController()
                guard let transactionsViewController = self.tradeItViewControllerProvider.provideViewController(forStoryboardId: .transactionsView) as? TradeItTransactionsViewController else { return }
                transactionsViewController.enableThemeOnLoad = false
                transactionsViewController.enableCustomNavController()
                transactionsViewController.linkedBrokerAccount = linkedBrokerAccount
                navController.pushViewController(transactionsViewController, animated: false)
                viewController.present(navController, animated: true, completion: nil)
            }, onFailure: {
                print("TouchId access denied")
            }
        )
    }
}
