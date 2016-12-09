import UIKit

class TradeItAccountSelectionViewController: TradeItViewController, TradeItAccountSelectionTableViewManagerDelegate {
    let linkedBrokerManager = TradeItSDK.linkedBrokerManager
    var accountSelectionTableManager = TradeItAccountSelectionTableViewManager()

    @IBOutlet weak var accountsTableView: UITableView!

    var selectedLinkedBroker: TradeItLinkedBroker?
    var delegate: TradeItAccountSelectionViewControllerDelegate?
    var alertManager = TradeItAlertManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSelectionTableManager.delegate = self
        self.accountSelectionTableManager.accountsTable = self.accountsTableView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let enabledBrokers = self.linkedBrokerManager?.getAllEnabledLinkedBrokers()
        self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: enabledBrokers!)
    }
    
    // MARK: TradeItAccounSelectionTableViewManagerDelegate
    
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItAccountSelectionTableViewManager,
                          onRefreshComplete: @escaping ([TradeItLinkedBroker]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        self.linkedBrokerManager?.authenticateAll(
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
                        onRefreshComplete(self.linkedBrokerManager?.getAllEnabledLinkedBrokers())
                    }
                )
            },
            onFinished: {
                self.linkedBrokerManager?.refreshAccountBalances(
                    onFinished:  {
                        onRefreshComplete(self.linkedBrokerManager?.getAllEnabledLinkedBrokers())
                    }
                )
            }
        )
    }
    
    func linkedBrokerAccountWasSelected(_ linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.delegate?.accountSelectionViewController(self, didSelectLinkedBrokerAccount: linkedBrokerAccount)
    }
}

protocol TradeItAccountSelectionViewControllerDelegate {
    func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount)
}
