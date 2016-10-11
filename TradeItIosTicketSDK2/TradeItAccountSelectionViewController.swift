import UIKit

class TradeItAccountSelectionViewController: UIViewController, TradeItAccountSelectionTableViewManagerDelegate {
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var accountSelectionTableManager = TradeItAccountSelectionTableViewManager()

    @IBOutlet weak var accountsTableView: UITableView!
    
    var selectedLinkedBroker: TradeItLinkedBroker!
    var delegate: TradeItAccountSelectionViewControllerDelegate?
    var alertManager = TradeItAlertManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        self.accountSelectionTableManager.delegate = self
        self.accountSelectionTableManager.accountsTable = self.accountsTableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let enabledBrokers = self.linkedBrokerManager.getAllEnabledLinkedBrokers()
        self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: enabledBrokers)
    }
    
    // MARK: TradeItAccounSelectionTableViewManagerDelegate
    
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItAccountSelectionTableViewManager,
                                                               onRefreshComplete: (withLinkedBrokers: [TradeItLinkedBroker]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        self.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, onAnswerSecurityQuestion: (String) -> Void, onCancelSecurityQuestion: () -> Void) in
                self.alertManager.show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: onAnswerSecurityQuestion,
                    onCancelSecurityQuestion: onCancelSecurityQuestion
                )
            },
            onFailure:  { (tradeItErrorResult: TradeItErrorResult, linkedBroker: TradeItLinkedBroker) -> Void in
                self.alertManager.show(tradeItErrorResult: tradeItErrorResult, onViewController: self, withLinkedBroker: linkedBroker, onFinished: {
                        onRefreshComplete(withLinkedBrokers: self.linkedBrokerManager.getAllEnabledLinkedBrokers())
                    }
                )
            },
            onFinished: {
                self.linkedBrokerManager.refreshAccountBalances(
                    onFinished:  {
                        onRefreshComplete(withLinkedBrokers: self.linkedBrokerManager.getAllEnabledLinkedBrokers())
                    }
                )
            }
        )
    }
    
    func linkedBrokerAccountWasSelected(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.delegate?.accountSelectionViewController(self, didSelectLinkedBrokerAccount: linkedBrokerAccount)
    }
}

protocol TradeItAccountSelectionViewControllerDelegate {
    func accountSelectionViewController(accountSelectionViewController: TradeItAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount)
}
