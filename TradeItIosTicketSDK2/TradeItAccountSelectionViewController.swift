import UIKit

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
        self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: self.linkedBrokerManager.getAllEnabledLinkedBrokers())
    }
    
    // MARK: TradeItAccounSelectionTableViewManagerDelegate
    
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItAccountSelectionTableViewManager,
                                                                onRefreshComplete: (withLinkedBrokers: [TradeItLinkedBroker]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        self.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { (TradeItSecurityQuestionResult) -> String in
                // TODO: GET
                return "MY SPECIAL SECURITY ANSWER"
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
        self.delegate?.linkedBrokerAccountWasSelected(self, linkedBrokerAccount: linkedBrokerAccount)
    }

}

protocol TradeItAccountSelectionViewControllerDelegate {
    func linkedBrokerAccountWasSelected(fromAccountSelectionViewController: TradeItAccountSelectionViewController, linkedBrokerAccount: TradeItLinkedBrokerAccount)
}
