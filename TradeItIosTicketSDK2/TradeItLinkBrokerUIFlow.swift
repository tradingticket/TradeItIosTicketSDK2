import UIKit
import TradeItIosEmsApi

class TradeItLinkBrokerUIFlow: NSObject,
                               TradeItWelcomeViewControllerDelegate,
                               TradeItSelectBrokerViewControllerDelegate,
                               TradeItLoginViewControllerDelegate {

    let linkedBrokerManager: TradeItLinkedBrokerManager
    let viewControllerProvider: TradeItViewControllerProvider
    var onLinkedCallback: ((UINavigationController, TradeItLinkedBrokerAccount?) -> Void)?
    var onFlowAbortedCallback: ((UINavigationController) -> Void)?
    var promptForAccountSelection = false

    init(linkedBrokerManager: TradeItLinkedBrokerManager) {
        self.linkedBrokerManager = linkedBrokerManager
        self.viewControllerProvider = TradeItViewControllerProvider()
    }

    func launch(inViewController viewController: UIViewController,
                                 showWelcomeScreen: Bool,
                                 promptForAccountSelection: Bool,
                                 onLinked: (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void,
                                 onFlowAborted: (presentedNavController: UINavigationController) -> Void) {
        self.promptForAccountSelection = promptForAccountSelection
        self.onLinkedCallback = onLinked
        self.onFlowAbortedCallback = onFlowAborted

        let initialStoryboardId: TradeItStoryboardID = showWelcomeScreen ? .welcomeView : .selectBrokerView

        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: initialStoryboardId)

        if let rootViewController = navController.viewControllers[0] as? TradeItWelcomeViewController {
            rootViewController.delegate = self
        } else if let rootViewController = navController.viewControllers[0] as? TradeItSelectBrokerViewController {
            rootViewController.delegate = self
        }

        viewController.presentViewController(navController,
                                             animated: true,
                                             completion: nil)
    }

    // MARK: TradeItWelcomeViewControllerDelegate

    func getStartedButtonWasTapped(fromWelcomeViewController: TradeItWelcomeViewController) {
        let selectBrokerViewController = self.viewControllerProvider.provideViewController(withStoryboardId: TradeItStoryboardID.selectBrokerView) as! TradeItSelectBrokerViewController

        selectBrokerViewController.delegate = self
        fromWelcomeViewController.navigationController!.pushViewController(selectBrokerViewController, animated: true)
//        fromViewController.navigationController!.viewControllers = [selectBrokerController]
    }

    func cancelWasTapped(fromWelcomeViewController welcomeViewController: TradeItWelcomeViewController) {
        self.onFlowAbortedCallback?(welcomeViewController.navigationController!)
    }

    // MARK: TradeItSelectBrokerViewControllerDelegate

    func brokerWasSelected(fromSelectBrokerViewController: TradeItSelectBrokerViewController, broker: TradeItBroker) {
        let loginViewController = self.viewControllerProvider.provideViewController(withStoryboardId: TradeItStoryboardID.loginView) as! TradeItLoginViewController
        loginViewController.delegate = self
        loginViewController.selectedBroker = broker
        fromSelectBrokerViewController.navigationController!.pushViewController(loginViewController, animated: true)
    }

    func cancelWasTapped(fromSelectBrokerViewController selectBrokerViewController: TradeItSelectBrokerViewController) {
        self.onFlowAbortedCallback?(selectBrokerViewController.navigationController!)
    }

    // MARK: TradeItLoginViewControllerDelegate

    func brokerLinked(fromTradeItLoginViewController: TradeItLoginViewController, withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.onLinkedCallback?(fromTradeItLoginViewController.navigationController!, nil)
    }
}
