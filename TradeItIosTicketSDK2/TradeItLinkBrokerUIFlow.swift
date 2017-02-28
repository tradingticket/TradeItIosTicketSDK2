import UIKit
import MBProgressHUD

class TradeItLinkBrokerUIFlow: NSObject,
                               TradeItWelcomeViewControllerDelegate {

    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var onLinkedCallback: ((UINavigationController, _ linkedBroker: TradeItLinkedBroker) -> Void)?
    var onFlowAbortedCallback: ((UINavigationController) -> Void)?

    var oAuthCallbackUrl: URL?

    func pushLinkBrokerFlow(onNavigationController navController: UINavigationController,
                            asRootViewController: Bool,
                            showWelcomeScreen: Bool,
                            oAuthCallbackUrl: URL) {
        self.oAuthCallbackUrl = oAuthCallbackUrl

        let initialViewController = self.getInitialViewController(showWelcomeScreen: showWelcomeScreen)

        if (asRootViewController) {
            navController.setViewControllers([initialViewController], animated: true)
        } else {
            navController.pushViewController(initialViewController, animated: true)
        }
    }

    func presentLinkBrokerFlow(fromViewController viewController: UIViewController,
                               showWelcomeScreen: Bool,
                               oAuthCallbackUrl: URL) {
        self.oAuthCallbackUrl = oAuthCallbackUrl

        let initialViewController = self.getInitialViewController(showWelcomeScreen: showWelcomeScreen)

        let navController = UINavigationController()
        navController.setViewControllers([initialViewController], animated: true)

        viewController.present(navController, animated: true, completion: nil)
    }

    func presentRelinkBrokerFlow(inViewController viewController: UIViewController,
                                                 linkedBroker: TradeItLinkedBroker,
                                                 oAuthCallbackUrl: URL) {
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
                UIApplication.shared.openURL(url)
            },
            onFailure: { errorResult in
                TradeItAlertManager().showError(errorResult, onViewController: viewController)
            }
        )
    }

    // MARK: Private

    private func getInitialViewController(showWelcomeScreen: Bool) -> UIViewController {
        let initialStoryboardId: TradeItStoryboardID = showWelcomeScreen ? .welcomeView : .selectBrokerView

        let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: initialStoryboardId)

        if let welcomeViewController = initialViewController as? TradeItWelcomeViewController {
            welcomeViewController.delegate = self
        } else if let selectBrokerViewController = initialViewController as? TradeItSelectBrokerViewController {
            selectBrokerViewController.oAuthCallbackUrl = oAuthCallbackUrl
        }
        
        return initialViewController
    }
    
    // MARK: TradeItWelcomeViewControllerDelegate

    func getStartedButtonWasTapped(_ fromWelcomeViewController: TradeItWelcomeViewController) {
        let selectBrokerViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.selectBrokerView) as! TradeItSelectBrokerViewController

        selectBrokerViewController.oAuthCallbackUrl = self.oAuthCallbackUrl

//        fromWelcomeViewController.navigationController!.pushViewController(selectBrokerViewController, animated: true)
        fromWelcomeViewController.navigationController!.setViewControllers([selectBrokerViewController], animated: true)
    }
}
