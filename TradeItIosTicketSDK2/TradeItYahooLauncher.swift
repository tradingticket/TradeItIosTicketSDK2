import UIKit
import SafariServices

@objc public class TradeItYahooLauncher: NSObject {
    let viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var deviceManager = TradeItDeviceManager()
    let tradingUIFlow = TradeItYahooTradingUIFlow()
    let oAuthCompletionUIFlow = TradeItYahooOAuthCompletionUIFlow()

    override internal init() {}
    
    public func launchOAuth(fromViewController viewController: UIViewController, withCallbackUrl callbackUrl: URL) {
        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: TradeItStoryboardID.yahooBrokerSelectionView)
        
        if let brokerSelectionViewController = navController.viewControllers.last as? TradeItYahooBrokerSelectionViewController {
            brokerSelectionViewController.oAuthCallbackUrl = callbackUrl
            viewController.present(navController, animated: true)
        }
    }

    public func handleOAuthCallback(
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

    public func launchTrading(
        fromViewController viewController: UIViewController,
        withOrder order: TradeItOrder,
        onViewPortfolioTappedHandler: @escaping OnViewPortfolioTappedHandler
    ) {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                print("Access granted")
                self.tradingUIFlow.presentTradingFlow(
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
}
