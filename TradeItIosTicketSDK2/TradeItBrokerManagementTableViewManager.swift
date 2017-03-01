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
        switch indexPath.section {
        case brokersTableSectionIndex:
            self.delegate?.linkedBrokerWasSelected(self.linkedBrokers[indexPath.row])
        case addAccountTableSectionIndex:
            self.delegate?.addAccountWasTapped()
        default:
            return
        }
    }
    
    // MARK: UITableViewDataSource

    private let brokersTableSectionIndex = 0
    private let addAccountTableSectionIndex = 1

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case brokersTableSectionIndex:
            return self.linkedBrokers.count
        case addAccountTableSectionIndex:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case brokersTableSectionIndex:
            let brokerManagerCellIdentifier = "BROKER_MANAGER_CELL_ID"
            let cell = tableView.dequeueReusableCell(withIdentifier: brokerManagerCellIdentifier) as! TradeItBrokerManagementTableViewCell
            cell.populate(withLinkedBroker: self.linkedBrokers[indexPath.row])
            return cell
        case addAccountTableSectionIndex:
            let brokerManagerCellIdentifier = "BROKER_MANAGER_ADD_ACCOUNT_CELL_ID"
            let cell = tableView.dequeueReusableCell(withIdentifier: brokerManagerCellIdentifier)
            TradeItThemeConfigurator.configure(view: cell)
            return cell!
        default:
            return UITableViewCell()
        }
    }
}

protocol TradeItBrokerManagementViewControllerBrokersTableDelegate: class {
    func linkedBrokerWasSelected(_ selectedLinkedBroker: TradeItLinkedBroker)
    func addAccountWasTapped()
}
