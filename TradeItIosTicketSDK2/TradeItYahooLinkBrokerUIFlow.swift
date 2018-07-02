import UIKit
import MBProgressHUD
import SafariServices

@objc class TradeItYahooLinkBrokerUIFlow: NSObject, LinkBrokerUIFlow {
    let viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    private var _alertManager: TradeItAlertManager?
    private var alertManager: TradeItAlertManager {
        get { // Need this to avoid infinite constructor loop
            self._alertManager ??= TradeItAlertManager(linkBrokerUIFlow: TradeItYahooLinkBrokerUIFlow())
            return self._alertManager!
        }
    }
    var oAuthCallbackUrl: URL?

    weak var delegate: YahooLauncherDelegate?

    override internal init() {
        super.init()
    }

    func pushLinkBrokerFlow(
        onNavigationController navController: UINavigationController,
        asRootViewController: Bool,
        showWelcomeScreen: Bool,
        showOpenAccountButton: Bool = true,
        oAuthCallbackUrl: URL
    ) {
        self.oAuthCallbackUrl = oAuthCallbackUrl

        guard let brokerSelectionViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .yahooBrokerSelectionView) as? TradeItYahooBrokerSelectionViewController else {
            print("TradeItSDK ERROR: Could not instantiate TradeItYahooBrokerSelectionViewController from storyboard!")
            return
        }

        brokerSelectionViewController.oAuthCallbackUrl = oAuthCallbackUrl
        brokerSelectionViewController.delegate = self.delegate

        if (asRootViewController) {
            navController.setViewControllers([brokerSelectionViewController], animated: true)
        } else {
            navController.pushViewController(brokerSelectionViewController, animated: true)
        }
    }

    func presentLinkBrokerFlow(
        fromViewController viewController: UIViewController,
        showWelcomeScreen: Bool = true,
        showOpenAccountButton: Bool = true,
        oAuthCallbackUrl: URL,
        delegate: YahooLauncherDelegate?
    ) {
        self.delegate = delegate

        self.presentLinkBrokerFlow(
            fromViewController: viewController,
            showWelcomeScreen: showWelcomeScreen,
            showOpenAccountButton: showOpenAccountButton,
            oAuthCallbackUrl: oAuthCallbackUrl
        )
    }

    func presentLinkBrokerFlow(
        fromViewController viewController: UIViewController,
        showWelcomeScreen: Bool = true,
        showOpenAccountButton: Bool = true,
        oAuthCallbackUrl: URL
    ) {
        self.oAuthCallbackUrl = oAuthCallbackUrl

        let navController = TradeItYahooNavigationController()

        guard let brokerSelectionViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooBrokerSelectionView) as? TradeItYahooBrokerSelectionViewController else {
            return print("TradeItSDK ERROR: Could not instantiate TradeItYahooBrokerSelectionViewController from storyboard!")
        }

        brokerSelectionViewController.oAuthCallbackUrl = oAuthCallbackUrl
        brokerSelectionViewController.delegate = self.delegate
        
        navController.pushViewController(brokerSelectionViewController, animated: false)
        viewController.present(navController, animated: true, completion: nil)
    }

    func presentRelinkBrokerFlow(
        inViewController viewController: UIViewController,
        linkedBroker: TradeItLinkedBroker,
        oAuthCallbackUrl: URL
    ) {
        let activityView = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        activityView.label.text = "Launching broker relinking"
        activityView.show(animated: true)

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupForTokenUpdateUrl(
            forLinkedBroker: linkedBroker,
            oAuthCallbackUrl: oAuthCallbackUrl,
            onSuccess: { url in
                activityView.hide(animated: true)
                let safariViewController = SFSafariViewController(url: url)
                viewController.present(safariViewController, animated: true, completion: nil)
            },
            onFailure: { errorResult in
                self.alertManager.showError(errorResult, onViewController: viewController)
                activityView.hide(animated: true)
            }
        )
    }
}
