import UIKit

class TradeItAccountSelectionViewController: TradeItViewController, TradeItAccountSelectionTableViewManagerDelegate {
    var accountSelectionTableManager = TradeItAccountSelectionTableViewManager()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var editAccountsButton: UIButton!

    var selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?
    internal weak var delegate: TradeItAccountSelectionViewControllerDelegate?
    var alertManager = TradeItAlertManager()
    var promptText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSelectionTableManager.delegate = self
        self.accountSelectionTableManager.accountsTable = self.accountsTableView
        self.accountsTableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.promptLabel.text = promptText ?? "SELECT AN ACCOUNT FOR TRADING"
        let linkedBrokers = TradeItSDK.linkedBrokerManager.getAllEnabledAndActivationInProgressLinkedBrokers()
        self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: linkedBrokers, withSelectedLinkedBrokerAccount: selectedLinkedBrokerAccount)
        if linkedBrokers.isEmpty {
            editAccountsButton.setTitle("Link Account", for: .normal)
            self.promptLabel.text = "NO ACCOUNTS LINKED"
        }
    }
    
    override func configureNavigationItem() {
        let authenticatedEnabledBrokers = TradeItSDK.linkedBrokerManager.getAllAuthenticatedAndEnabledAccounts()

        var isRootScreen = true

        if let navStackCount = self.navigationController?.viewControllers.count {
            isRootScreen = (navStackCount == 1)
        }

        if authenticatedEnabledBrokers.isEmpty || isRootScreen {
            self.createCloseButton()
        }
    }
    
    override func closeButtonWasTapped(_ sender: UIBarButtonItem) {
            self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TradeItAccounSelectionTableViewManagerDelegate
    
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItAccountSelectionTableViewManager,
                          onRefreshComplete: @escaping ([TradeItLinkedBroker]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        TradeItSDK.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, onAnswerSecurityQuestion, onCancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: onAnswerSecurityQuestion,
                    onCancelSecurityQuestion: onCancelSecurityQuestion
                )
            },
            onFailure:  { error, linkedBroker in
                self.alertManager.showRelinkError(error, withLinkedBroker: linkedBroker, onViewController: self, onFinished: {
                        // QUESTION: is this just going to re-run authentication for all linked brokers again if one failed?
                        onRefreshComplete(TradeItSDK.linkedBrokerManager.getAllEnabledAndActivationInProgressLinkedBrokers())
                    }
                )
            },
            onFinished: {
                TradeItSDK.linkedBrokerManager.refreshAccountBalances(
                    onFinished:  {
                        onRefreshComplete(TradeItSDK.linkedBrokerManager.getAllEnabledAndActivationInProgressLinkedBrokers())
                    }
                )
            }
        )
    }
    
    func authenticate(linkedBroker: TradeItLinkedBroker) {
        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                linkedBroker.refreshAccountBalances(onFinished: { 
                    self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: TradeItSDK.linkedBrokerManager.getAllEnabledAndActivationInProgressLinkedBrokers(), withSelectedLinkedBrokerAccount: self.selectedLinkedBrokerAccount)
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
            onFailure:  { error in
                self.alertManager.showRelinkError(error, withLinkedBroker: linkedBroker, onViewController: self, onFinished: {})
            }
        )
    }
    
    func relink(linkedBroker: TradeItLinkedBroker) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: linkedBroker,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl
        )
    }
    
    func linkedBrokerAccountWasSelected(_ linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.delegate?.accountSelectionViewController(self, didSelectLinkedBrokerAccount: linkedBrokerAccount)
    }
}

protocol TradeItAccountSelectionViewControllerDelegate: class {
    func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount)
}
