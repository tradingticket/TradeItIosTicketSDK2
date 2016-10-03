import UIKit

class TradeItAccountSelectionViewController: UIViewController {

    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var accountSelectionTableManager = TradeItAccountSelectionTableViewManager()

    @IBOutlet weak var accountsTableView: UITableView!
    
    var selectedLinkedBroker: TradeItLinkedBroker!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSelectionTableManager.accountsTable = self.accountsTableView
    }

    override func viewWillAppear(animated: Bool) {
        self.accountSelectionTableManager.updateLinkedBrokers(withLinkedBrokers: self.linkedBrokerManager.getAllEnabledLinkedBrokers())
    }
    

}
