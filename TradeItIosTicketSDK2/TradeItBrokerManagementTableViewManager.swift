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
    
    weak var delegate: TradeItBrokerManagementViewControllerBrokersTableDelegate?
    
    func updateLinkedBrokers(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker]) {
        self.linkedBrokers = linkedBrokers
        self.brokersTable?.reloadData()
    }


    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.linkedBrokers.count {
            self.delegate?.linkedBrokerWasSelected(self.linkedBrokers[indexPath.row])
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.linkedBrokers.count + 1 // We add one extra cell for the 'Add Account' action
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < self.linkedBrokers.count {
            let brokerManagerCellIdentifier = "BROKER_MANAGER_CELL_ID"
            let cell = tableView.dequeueReusableCellWithIdentifier(brokerManagerCellIdentifier) as! TradeItBrokerManagementTableViewCell
            cell.populate(withLinkedBroker: self.linkedBrokers[indexPath.row])
            return cell
        }
        else { // last cell is the 'Add Account' action
            let brokerManagerCellIdentifier = "BROKER_MANAGER_ADD_ACCOUNT_CELL_ID"
            let cell = tableView.dequeueReusableCellWithIdentifier(brokerManagerCellIdentifier)
            return cell!
        }
    }

}

protocol TradeItBrokerManagementViewControllerBrokersTableDelegate: class {
    func linkedBrokerWasSelected(selectedLinkedBroker: TradeItLinkedBroker)
}
