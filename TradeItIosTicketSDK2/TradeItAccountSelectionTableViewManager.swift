import UIKit

class TradeItAccountSelectionTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokers: [TradeItLinkedBroker] = []
    private var refreshControl: UIRefreshControl?
    internal weak var delegate: TradeItAccountSelectionTableViewManagerDelegate?

    var accountsTable: UITableView? {
        get {
            return _table
        }
        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }
    }
    
    func updateLinkedBrokers(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker]) {
        self.linkedBrokers = linkedBrokers
        self.accountsTable?.reloadData()
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linkedBroker = self.linkedBrokers[indexPath.section]
        let selectedAccount = linkedBroker.getEnabledAccounts()[indexPath.row]
        self.delegate?.linkedBrokerAccountWasSelected(selectedAccount)
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
            return self.linkedBrokers.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let linkedBroker = self.linkedBrokers[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_HEADER_ID") as! TradeItAccountSelectionTableViewHeader
        cell.populate(withLinkedBroker: linkedBroker)
        TradeItThemeConfigurator.configureTableHeader(header: cell)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfLinkedAccounts = 0

        if self.linkedBrokers.count > 0 {
            let linkedBroker = self.linkedBrokers[section]
            numberOfLinkedAccounts = linkedBroker.getEnabledAccounts().count
        }

        return numberOfLinkedAccounts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linkedBroker = self.linkedBrokers[indexPath.section]
        let linkedBrokerAccount = linkedBroker.getEnabledAccounts()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_CELL_ID") as! TradeItAccountSelectionTableViewCell
        cell.populate(withLinkedBrokerAccount: linkedBrokerAccount)
        TradeItThemeConfigurator.configureTableCell(cell: cell)
        return cell
    }
    
    // MARK: Private
    
    func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self,
                                 action: #selector(refreshControlActivated),
                                 for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
    
    func refreshControlActivated() {
        self.delegate?.refreshRequested(fromAccountSelectionTableViewManager: self,
                                        onRefreshComplete: { linkedBrokers in
                                            if let linkedBrokers = linkedBrokers {
                                                self.updateLinkedBrokers(withLinkedBrokers: linkedBrokers)
                                            }
                                            
                                            self.refreshControl?.endRefreshing()
                                        })
    }
}

protocol TradeItAccountSelectionTableViewManagerDelegate: class {
    func linkedBrokerAccountWasSelected(_ linkedBrokerAccount: TradeItLinkedBrokerAccount)
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItAccountSelectionTableViewManager,
                          onRefreshComplete: @escaping ([TradeItLinkedBroker]?) -> Void)
}


