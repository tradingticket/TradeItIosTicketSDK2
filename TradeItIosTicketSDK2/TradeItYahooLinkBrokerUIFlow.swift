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

    override internal init() {
        super.init()
    }

    func pushLinkBrokerFlow(
        onNavigationController navController: UINavigationController,
        asRootViewController: Bool,
        showWelcomeScreen: Bool,
        oAuthCallbackUrl: URL
    ) {
        self.oAuthCallbackUrl = oAuthCallbackUrl

        guard let selectBrokerViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .yahooBrokerSelectionView) as? TradeItYahooBrokerSelectionViewController else {
            print("TradeItSDK ERROR: Could not instantiate TradeItYahooBrokerSelectionViewController!")
            return
        }

        if (asRootViewController) {
            navController.setViewControllers([selectBrokerViewController], animated: true)
        } else {
            navController.pushViewController(selectBrokerViewController, animated: true)
        }
    }

    func presentLinkBrokerFlow(
        fromViewController viewController: UIViewController,
        showWelcomeScreen: Bool,
        oAuthCallbackUrl: URL
    ) {
        self.oAuthCallbackUrl = oAuthCallbackUrl

        guard let selectBrokerViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .yahooBrokerSelectionView) as? TradeItYahooBrokerSelectionViewController else {
            print("TradeItSDK ERROR: Could not instantiate TradeItYahooBrokerSelectionViewController!")
            return
        }

        let navController = UINavigationController()
        navController.setViewControllers([selectBrokerViewController], animated: true)

        viewController.present(navController, animated: true, completion: nil)
    }

    func presentRelinkBrokerFlow(
        inViewController viewController: UIViewController,
        linkedBroker: TradeItLinkedBroker,
        oAuthCallbackUrl: URL
    ) {
        guard let userId = linkedBroker.linkedLogin.userId else {
            print("TradeItSDK ERROR: userId not set for linked broker in presentRelinkBrokerFlow()!")
            return
        }

        let activityView = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        activityView.label.text = "Launching broker relinking"
        activityView.show(animated: true)

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupForTokenUpdateUrl(
            withBroker: linkedBroker.brokerName,
            userId: userId,
            oAuthCallbackUrl: oAuthCallbackUrl,
            onSuccess: { url in
                activityView.hide(animated: true)
                let safariViewController = SFSafariViewController(url: url)
                viewController.present(safariViewController, animated: true, completion: nil)
            },
            onFailure: { errorResult in
                self.alertManager.showError(errorResult, onViewController: viewController)
            }
        )
    }
}
