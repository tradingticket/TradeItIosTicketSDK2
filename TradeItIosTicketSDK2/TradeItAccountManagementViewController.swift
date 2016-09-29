import UIKit
import TradeItIosEmsApi

class TradeItAccountManagementViewController: UIViewController, TradeItAccountManagementTableViewManagerDelegate {
    var tradeItAlert = TradeItAlert()
    var linkedBroker: TradeItLinkedBroker!
    var accountManagementTableManager = TradeItAccountManagementTableViewManager()
    var linkedBrokerManager = TradeItLauncher.linkedBrokerManager
//    var refreshControl: UIRefreshControl = UIRefreshControl()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    @IBOutlet weak var accountsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountManagementTableManager.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        if let linkedBroker = self.linkedBroker {
            self.navigationItem.title = linkedBroker.linkedLogin.broker
            self.accountManagementTableManager.updateAccounts(withAccounts: self.linkedBroker.accounts)
        }
    }

    // MARK: IBActions

    @IBAction func relinkAccountWasTapped(sender: AnyObject) {
        let linkedLogin = self.linkedBroker.linkedLogin
        let broker = TradeItBroker(shortName: linkedLogin.broker, longName: linkedLogin.broker)
        let controllersStack = self.navigationController?.viewControllers
        self.linkBrokerUIFlow.launchIntoLoginScreen(
            inViewController: self,
            selectedBroker: broker,
            selectedReLinkedBroker: self.linkedBroker,
            mode: TradeItLoginViewControllerMode.relink,
            onLinked: { (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void in
                presentedNavController.setViewControllers(controllersStack!, animated: true)
                self.linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.accountManagementTableManager.updateAccounts(withAccounts: self.linkedBroker.accounts)
                })
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                //Nothing to do ?
            }
        )
    }
    
    @IBAction func unlinkAccountWasTapped(sender: AnyObject) {
        self.tradeItAlert.showValidationAlert(onController: self,
                                              withTitle: "Unlink \(self.linkedBroker.linkedLogin.broker)",
                                              withMessage: "Are you sure you want to unlink your account and remove all the associated data ?",
                                              withActionOkTitle: "Unlink",
            onValidate: {
                self.linkedBrokerManager.unlinkBroker(self.linkedBroker)

                if self.linkedBrokerManager.linkedBrokers.count > 0 {
                    self.performSegueWithIdentifier("UNWIND_TO_BROKER_MANAGEMENT", sender: self)
                } else {
                    // Launch Welcome flow
                }
            },
            onCancel: {
                //Nothing to do
            }
        )
    }

    // MARK: TradeItAccountManagementTableViewManagerDelegate

    func refreshRequested(fromAccountManagementTableViewManager manager: TradeItAccountManagementTableViewManager,
                                                                onRefreshComplete: (withAccounts: [TradeItLinkedBrokerAccount]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        self.linkedBroker.authenticate(
            onSuccess: { () -> Void in
                self.linkedBroker.refreshAccountBalances(
                    onFinished: {
                        onRefreshComplete(withAccounts: self.linkedBroker.accounts)
                })
            },
            onSecurityQuestion: { (tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String in
                print("Security question result: \(tradeItSecurityQuestionResult)")

                // TODO: Get answer from user...
                return "Some Answer"
            },
            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                self.tradeItAlert.showTradeItErrorResultAlert(onController: self, withError: tradeItErrorResult)
                onRefreshComplete(withAccounts: nil)
            }
        )
    }
}
