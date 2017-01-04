import UIKit

class TradeItBrokerManagementTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokers: [TradeItLinkedBroker] = []
    var brokersTable: UITableView? {
        get {
            return _table
        }
        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                _table = newTable
            }
        }
    }
    
    internal weak var delegate: TradeItBrokerManagementViewControllerBrokersTableDelegate?
    
    func updateLinkedBrokers(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker]) {
        self.linkedBrokers = linkedBrokers
        self.brokersTable?.reloadData()
    }


    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.linkedBrokers.count {
            self.delegate?.linkedBrokerWasSelected(self.linkedBrokers[indexPath.row])
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.linkedBrokers.count + 1 // We add one extra cell for the 'Add Account' action
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.linkedBrokers.count {
            let brokerManagerCellIdentifier = "BROKER_MANAGER_CELL_ID"
            let cell = tableView.dequeueReusableCell(withIdentifier: brokerManagerCellIdentifier) as! TradeItBrokerManagementTableViewCell
            cell.populate(withLinkedBroker: self.linkedBrokers[indexPath.row])
            TradeItThemeConfigurator.configureTableCell(cell: cell)
            return cell
        }
        else { // last cell is the 'Add Account' action
            let brokerManagerCellIdentifier = "BROKER_MANAGER_ADD_ACCOUNT_CELL_ID"
            let cell = tableView.dequeueReusableCell(withIdentifier: brokerManagerCellIdentifier)
            TradeItThemeConfigurator.configureTableCell(cell: cell)
            return cell!
        }
    }
}

protocol TradeItBrokerManagementViewControllerBrokersTableDelegate: class {
    func linkedBrokerWasSelected(_ selectedLinkedBroker: TradeItLinkedBroker)
}
