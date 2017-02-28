import UIKit


class TradeItAccountManagementViewController: CloseableViewController, TradeItAccountManagementTableViewManagerDelegate {
    var alertManager = TradeItAlertManager()
    var linkedBroker: TradeItLinkedBroker!
    var accountManagementTableManager = TradeItAccountManagementTableViewManager()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    @IBOutlet weak var accountsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.linkedBroker != nil, "TradeItSDK ERROR: TradeItAccountManagementViewController loaded without setting linkedBroker!")

        self.accountManagementTableManager.delegate = self
        self.accountManagementTableManager.accountsTableView = self.accountsTableView
    }

    override func viewWillAppear(_ animated: Bool) {
        if let linkedBroker = self.linkedBroker {
            self.navigationItem.title = linkedBroker.brokerName
            self.accountManagementTableManager.updateAccounts(withAccounts: self.linkedBroker.accounts)
        }
    }

    // MARK: IBActions

    @IBAction func relinkAccountWasTapped(_ sender: AnyObject) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: self.linkedBroker,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl)
    }
    
    @IBAction func unlinkAccountWasTapped(_ sender: AnyObject) {
        self.alertManager.showAlert(
            onViewController: self,
            withTitle: "Unlink \(self.linkedBroker.brokerName)",
            withMessage: "Are you sure you want to unlink your account and remove all the associated data?",
            withActionTitle: "Unlink",
            onAlertActionTapped: { () -> Void in
                TradeItSDK.linkedBrokerManager.unlinkBroker(self.linkedBroker)

                // If the last linked broker was just unlinked then we need to use the TradeItBrokerManagementViewController
                // that preceeds this view controller in the nav stack to launch the broker linking flow so that we can pop
                // this view controller off the nav stack without the TradeItLinkBrokerUIFlow being garbage collected
                if let navController = self.navigationController,
                    let parentBrokerManagementView = navController.viewControllers[safe: navController.viewControllers.count - 2] as? TradeItBrokerManagementViewController {
                    if TradeItSDK.linkedBrokerManager.linkedBrokers.count == 0 {
                        parentBrokerManagementView.linkBrokerUIFlow.presentLinkBrokerFlow(
                            fromViewController: navController,
                            showWelcomeScreen: true,
                            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl
                        )
                    }
                    navController.popViewController(animated: true)
                }
            },
            showCancelAction: true
        )
    }

    // MARK: TradeItAccountManagementTableViewManagerDelegate

    func refreshRequested(fromAccountManagementTableViewManager manager: TradeItAccountManagementTableViewManager,
                                                                onRefreshComplete: @escaping (_ withAccounts: [TradeItLinkedBrokerAccount]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        self.linkedBroker.authenticateIfNeeded(
            onSuccess: {
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
                self.alertManager.showRelinkError(
                    error,
                    withLinkedBroker: self.linkedBroker,
                    onViewController: self,
                    onFinished : {
                        onRefreshComplete(self.linkedBroker.accounts)
                    }
                )
            }
        )
    }
}
