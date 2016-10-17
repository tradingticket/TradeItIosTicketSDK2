import UIKit


class TradeItAccountManagementViewController: UIViewController, TradeItAccountManagementTableViewManagerDelegate {
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

    override func viewWillAppear(animated: Bool) {
        if let linkedBroker = self.linkedBroker {
            self.navigationItem.title = linkedBroker.linkedLogin.broker
            self.accountManagementTableManager.updateAccounts(withAccounts: self.linkedBroker.accounts)
        }
    }

    // MARK: IBActions

    @IBAction func relinkAccountWasTapped(sender: AnyObject) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: self.linkedBroker,
            onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
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
        
        self.alertManager.showOn(viewController: self,
                                              withAlertTitle: "Unlink \(self.linkedBroker.linkedLogin.broker)",
                                              withAlertMessage: "Are you sure you want to unlink your account and remove all the associated data ?",
                                              withAlertActionTitle: "Unlink",
            onAlertActionTapped: { () -> Void in
                
                self.linkedBrokerManager.unlinkBroker(self.linkedBroker)

                if self.linkedBrokerManager.linkedBrokers.count > 0 {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.linkBrokerUIFlow.presentLinkBrokerFlow(
                        fromViewController: self,
                        showWelcomeScreen: true,
                        onLinked: { (presentedNavController, linkedBroker) in
                            presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                        }, onFlowAborted: { (presentedNavController) in
                            presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                            // For now go back to the broker selection screen which has the option to add a broker
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    )
                }
            })
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
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: (String) -> Void, cancelSecurityQuestion: () -> Void) in
                self.alertManager.show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                self.alertManager.show(
                    tradeItErrorResult: tradeItErrorResult,
                    onViewController: self,
                    withLinkedBroker: self.linkedBroker,
                    onFinished : { () -> Void in
                        onRefreshComplete(withAccounts: self.linkedBroker.accounts)
                })
            }
        )
    }
}
