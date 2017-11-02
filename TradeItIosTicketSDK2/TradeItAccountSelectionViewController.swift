import UIKit

class TradeItAccountSelectionViewController: TradeItViewController, TradeItAccountSelectionTableViewManagerDelegate {
    var accountSelectionTableManager = TradeItAccountSelectionTableViewManager()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var editAccountsButton: UIButton!
    @IBOutlet weak var adContainer: UIView!

    var selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?
    internal weak var delegate: TradeItAccountSelectionViewControllerDelegate?
    var alertManager = TradeItAlertManager()
    var promptText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSelectionTableManager.delegate = self
        self.accountSelectionTableManager.accountsTable = self.accountsTableView

        TradeItSDK.adService.populate(adContainer: adContainer, rootViewController: self, pageType: .general, position: .bottom)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let linkedBrokers = TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers()
        self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: linkedBrokers, withSelectedLinkedBrokerAccount: selectedLinkedBrokerAccount)

        self.title = promptText ?? "Select account for trading"

        if linkedBrokers.isEmpty {
            editAccountsButton.setTitle("Link Account", for: .normal)
        }
    }
    
    override func configureNavigationItem() {
        let authenticatedEnabledBrokers = TradeItSDK.linkedBrokerManager.getAllAuthenticatedAndEnabledAccounts()
        var isRootScreen = true
        
        if let navStackCount = self.navigationController?.viewControllers.count {
            isRootScreen = (navStackCount == 1)
        }
        
        let accountIndexes = authenticatedEnabledBrokers.flatMap { $0.accountIndex }
        let selectedAccountIndex = self.selectedLinkedBrokerAccount?.accountIndex ?? ""
        if authenticatedEnabledBrokers.isEmpty || isRootScreen || !accountIndexes.contains(selectedAccountIndex) {
            self.createCloseButton()
        } else {
            self.navigationItem.leftBarButtonItem = nil
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
                self.alertManager.showAlertWithAction(
                    error: error,
                    withLinkedBroker: linkedBroker,
                    onViewController: self,
                    onFinished: {
                        // QUESTION: is this just going to re-run authentication for all linked brokers again if one failed?
                        onRefreshComplete(TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers())
                    }
                )
            },
            onFinished: {
                TradeItSDK.linkedBrokerManager.refreshAccountBalances(
                    onFinished:  {
                        onRefreshComplete(TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers())
                    }
                )
            }
        )
    }
    
    func authenticate(linkedBroker: TradeItLinkedBroker) {
        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.accountSelectionTableManager.updateLinkedBrokers(
                            withLinkedBrokers: TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers(),
                            withSelectedLinkedBrokerAccount: self.selectedLinkedBrokerAccount
                        )
                    }
                )
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
                self.alertManager.showAlertWithAction(
                    error: error,
                    withLinkedBroker: linkedBroker,
                    onViewController: self
                )
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
