import UIKit


class TradeItAccountManagementViewController: TradeItViewController, TradeItAccountManagementTableViewManagerDelegate {
    var alertManager = TradeItAlertManager()
    var linkedBroker: TradeItLinkedBroker!
    var accountManagementTableManager = TradeItAccountManagementTableViewManager()
    var linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    @IBOutlet weak var accountsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.linkedBroker == nil {
            assertionFailure("TradeItIosTicketSDK ERROR: TradeItAccountManagementViewController loaded without setting linkedBroker.")
        }

        self.accountManagementTableManager.delegate = self
        self.accountManagementTableManager.accountsTableView = self.accountsTableView
    }

    override func viewWillAppear(_ animated: Bool) {
        if let linkedBroker = self.linkedBroker {
            self.navigationItem.title = linkedBroker.linkedLogin.broker
            self.accountManagementTableManager.updateAccounts(withAccounts: self.linkedBroker.accounts)
        }
    }

    // MARK: IBActions

    @IBAction func relinkAccountWasTapped(_ sender: AnyObject) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: self.linkedBroker,
            onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                presentedNavController.dismiss(animated: true, completion: nil)
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
    
    @IBAction func unlinkAccountWasTapped(_ sender: AnyObject) {
        
        self.alertManager.showAlert(
            onViewController: self,
            withTitle: "Unlink \(self.linkedBroker.linkedLogin.broker)",
            withMessage: "Are you sure you want to unlink your account and remove all the associated data?",
            withActionTitle: "Unlink",
            onAlertActionTapped: { () -> Void in
                
                self.linkedBrokerManager?.unlinkBroker(self.linkedBroker)

                if (self.linkedBrokerManager?.linkedBrokers.count)! > 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.linkBrokerUIFlow.presentLinkBrokerFlow(
                        fromViewController: self,
                        showWelcomeScreen: true,
                        onLinked: { (presentedNavController, linkedBroker) in
                            presentedNavController.dismiss(animated: true, completion: nil)
                        }, onFlowAborted: { (presentedNavController) in
                            presentedNavController.dismiss(animated: true, completion: nil)
                            // For now go back to the broker selection screen which has the option to add a broker
                            self.navigationController?.popViewController(animated: true)
                        }
                    )
                }
            })
    }

    // MARK: TradeItAccountManagementTableViewManagerDelegate

    func refreshRequested(fromAccountManagementTableViewManager manager: TradeItAccountManagementTableViewManager,
                                                                onRefreshComplete: @escaping (_ withAccounts: [TradeItLinkedBrokerAccount]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        self.linkedBroker.authenticate(
            onSuccess: { () -> Void in
                self.linkedBroker.refreshAccountBalances(
                    onFinished: {
                        onRefreshComplete(self.linkedBroker.accounts)
                })
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { error in
                self.alertManager.showRelinkError(error,
                    withLinkedBroker: self.linkedBroker,
                    onViewController: self,
                    onFinished : {
                        onRefreshComplete(self.linkedBroker.accounts)
                })
            }
        )
    }
}
