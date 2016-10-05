import UIKit
import TradeItIosEmsApi

class TradeItAccountManagementViewController: UIViewController, TradeItAccountManagementTableViewManagerDelegate {
    var tradeItAlert = TradeItAlert()
    var linkedBroker: TradeItLinkedBroker!
    var accountManagementTableManager = TradeItAccountManagementTableViewManager()
    var linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    @IBOutlet weak var accountsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountManagementTableManager.delegate = self
        self.accountManagementTableManager.accountsTableView = self.accountsTableView
    }

    override func viewWillAppear(animated: Bool) {
        if let linkedBroker = self.linkedBroker {
            self.navigationItem.title = linkedBroker.linkedLogin.broker
            self.accountManagementTableManager.updateAccounts(withAccounts: self.linkedBroker.accounts)
        }
    }

    // MARK: IBActions

    @IBAction func relinkAccountWasTapped(sender: AnyObject) {
        self.linkBrokerUIFlow.launchRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: self.linkedBroker,
            onLinked: { (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void in
                presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                self.linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.accountManagementTableManager.updateAccounts(withAccounts: self.linkedBroker.accounts)
                })
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                //Nothing to do
            }
        )
    }
    
    @IBAction func unlinkAccountWasTapped(sender: AnyObject) {
        self.tradeItAlert.showValidationAlert(onViewController: self,
                                              title: "Unlink \(self.linkedBroker.linkedLogin.broker)",
                                              message: "Are you sure you want to unlink your account and remove all the associated data ?",
                                              actionTitle: "Unlink",
            onValidate: {
                self.linkedBrokerManager.unlinkBroker(self.linkedBroker)

                if self.linkedBrokerManager.linkedBrokers.count > 0 {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.linkBrokerUIFlow.launchLinkBrokerFlow(
                        inViewController: self,
                        showWelcomeScreen: true,
                        promptForAccountSelection: false,
                        onLinked: { (presentedNavController, selectedAccount) in
                            presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                        }, onFlowAborted: { (presentedNavController) in
                            presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                            // For now go back to the broker selection screen which has the option to add a broker
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    )
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
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: (String) -> Void) in
                self.tradeItAlert.show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion
                )
            },
            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                self.tradeItAlert.showTradeItErrorResultAlert(onViewController: self,
                                                              errorResult: tradeItErrorResult)
                onRefreshComplete(withAccounts: nil)
            }
        )
    }
}
