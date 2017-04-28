import UIKit

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
        onViewController safariViewController: UIViewController,
        oAuthCallbackUrl: URL,
        onOAuthCompletionSuccessHandler: OnOAuthCompletionSuccessHandler? = nil
    ) {
        print("=====> handleOAuthCallback: \(oAuthCallbackUrl.absoluteString)")

        let oAuthCallbackUrlParser = TradeItOAuthCallbackUrlParser(oAuthCallbackUrl: oAuthCallbackUrl)

        var parentViewController = safariViewController.presentingViewController

        // If this is a new link and not a relink then there is a SelectBrokerVC that also needs to be dismissed.
        if parentViewController?.childViewControllers.first is TradeItYahooBrokerSelectionViewController {
            parentViewController = parentViewController?.presentingViewController
        }

        guard let originalViewController = parentViewController else {
            preconditionFailure("View hierarchy in unknown state.")
        }


        originalViewController.dismiss(animated: true, completion: {
            self.oAuthCompletionUIFlow.presentOAuthCompletionFlow(
                fromViewController: originalViewController,
                oAuthCallbackUrlParser: oAuthCallbackUrlParser,
                onOAuthCompletionSuccessHandler: onOAuthCompletionSuccessHandler
            )
        })
    }

    public func launchTrading(fromViewController viewController: UIViewController, withOrder order: TradeItOrder) {
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
