import UIKit
import MBProgressHUD
import SafariServices

@objc public protocol LinkBrokerUIFlow {
    func pushLinkBrokerFlow(
        onNavigationController navController: UINavigationController,
        asRootViewController: Bool,
        showWelcomeScreen: Bool,
        hideOpenAccountButton: Bool,
        oAuthCallbackUrl: URL
    )

    func presentLinkBrokerFlow(
        fromViewController viewController: UIViewController,
        showWelcomeScreen: Bool,
        hideOpenAccountButton: Bool,
        oAuthCallbackUrl: URL
    )

    func presentRelinkBrokerFlow(
        inViewController viewController: UIViewController,
        linkedBroker: TradeItLinkedBroker,
        oAuthCallbackUrl: URL
    )

    // @optional func setOnLinkedCallback()
}

class TradeItLinkBrokerUIFlow: NSObject, TradeItWelcomeViewControllerDelegate, LinkBrokerUIFlow {
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var onFlowAbortedCallback: ((UINavigationController) -> Void)?
    private var _alertManager: TradeItAlertManager?
    private var alertManager: TradeItAlertManager {
        get { // Need this to avoid infinite constructor loop
            self._alertManager ??= TradeItAlertManager()
            return self._alertManager!
        }
    }

    var oAuthCallbackUrl: URL?
    var hideOpenAccountButton: Bool = false
    
    override internal init() {
        super.init()
    }

    func pushLinkBrokerFlow(
        onNavigationController navController: UINavigationController,
        asRootViewController: Bool,
        showWelcomeScreen: Bool,
        hideOpenAccountButton: Bool,
        oAuthCallbackUrl: URL
    ) {
        self.oAuthCallbackUrl = oAuthCallbackUrl
        self.hideOpenAccountButton = hideOpenAccountButton
        
        let initialViewController = self.getInitialViewController(showWelcomeScreen: showWelcomeScreen)

        if (asRootViewController) {
            navController.setViewControllers([initialViewController], animated: true)
        } else {
            navController.pushViewController(initialViewController, animated: true)
        }
    }

    func presentLinkBrokerFlow(
        fromViewController viewController: UIViewController,
        showWelcomeScreen: Bool,
        hideOpenAccountButton: Bool,
        oAuthCallbackUrl: URL
    ) {
        self.oAuthCallbackUrl = oAuthCallbackUrl
        self.hideOpenAccountButton = hideOpenAccountButton
        
        let initialViewController = self.getInitialViewController(showWelcomeScreen: showWelcomeScreen)

        let navController = UINavigationController()
        navController.setViewControllers([initialViewController], animated: true)

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
            }
        )
    }

    // MARK: Private

    private func getInitialViewController(showWelcomeScreen: Bool) -> UIViewController {
        let initialStoryboardId: TradeItStoryboardID = showWelcomeScreen ? .welcomeView : .selectBrokerView

        let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: initialStoryboardId)

        if let welcomeViewController = initialViewController as? TradeItWelcomeViewController {
            welcomeViewController.delegate = self
            welcomeViewController.oAuthCallbackUrl = oAuthCallbackUrl
        } else if let selectBrokerViewController = initialViewController as? TradeItSelectBrokerViewController {
            selectBrokerViewController.oAuthCallbackUrl = oAuthCallbackUrl
            selectBrokerViewController.hideOpenAccountButton = self.hideOpenAccountButton
        }
        
        return initialViewController
    }
    
    // MARK: TradeItWelcomeViewControllerDelegate

    func getStartedButtonWasTapped(_ fromWelcomeViewController: TradeItWelcomeViewController) {
        let selectBrokerViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.selectBrokerView) as! TradeItSelectBrokerViewController

        selectBrokerViewController.oAuthCallbackUrl = self.oAuthCallbackUrl
        selectBrokerViewController.hideOpenAccountButton = self.hideOpenAccountButton

//        fromWelcomeViewController.navigationController!.pushViewController(selectBrokerViewController, animated: true)
        fromWelcomeViewController.navigationController!.setViewControllers([selectBrokerViewController], animated: true)
    }
}
