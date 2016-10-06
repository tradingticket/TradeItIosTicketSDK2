import UIKit
import TradeItIosEmsApi

class TradeItAccountSelectionViewController: UIViewController, TradeItAccountSelectionTableViewManagerDelegate {
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var accountSelectionTableManager = TradeItAccountSelectionTableViewManager()

    @IBOutlet weak var accountsTableView: UITableView!
    
    var selectedLinkedBroker: TradeItLinkedBroker!
    var delegate: TradeItAccountSelectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSelectionTableManager.delegate = self
        self.accountSelectionTableManager.accountsTable = self.accountsTableView
    }

    override func viewWillAppear(animated: Bool) {
        let enabledBrokers = self.linkedBrokerManager.getAllEnabledLinkedBrokers()

        self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: enabledBrokers)
    }
    
    // MARK: TradeItAccounSelectionTableViewManagerDelegate
    
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItAccountSelectionTableViewManager,
                                                                onRefreshComplete: (withLinkedBrokers: [TradeItLinkedBroker]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        self.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: (String) -> Void) in
                TradeItAlert().show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion
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

    func accountSelectionCancelled(forAccountSelectionViewController accountSelectionViewController: TradeItAccountSelectionViewController)
}
