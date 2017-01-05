import UIKit

class TradeItAccountManagementTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokerAccounts: [TradeItLinkedBrokerAccount] = []
    private var refreshControl: UIRefreshControl?
    internal weak var delegate: TradeItAccountManagementTableViewManagerDelegate?

    var accountsTableView: UITableView? {
        get {
            return _table
        }
        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
                _table?.reloadData()
            }
        }
    }

    func updateAccounts(withAccounts linkedBrokerAccounts: [TradeItLinkedBrokerAccount]) {
        self.linkedBrokerAccounts = linkedBrokerAccounts
        self.accountsTableView?.reloadData()
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkedBrokerAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_MANAGEMENT_CELL_ID") as! TradeItAccountManagementTableViewCell
        cell.populate(self.linkedBrokerAccounts[indexPath.row])
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
        self.delegate?.refreshRequested(fromAccountManagementTableViewManager: self,
                                        onRefreshComplete: { (accounts: [TradeItLinkedBrokerAccount]?) in
                                            if let accounts = accounts {
                                                self.updateAccounts(withAccounts: accounts)
                                            }

                                            self.refreshControl?.endRefreshing()
                                        })
    }
}

protocol TradeItAccountManagementTableViewManagerDelegate: class {
    func refreshRequested(
        fromAccountManagementTableViewManager manager: TradeItAccountManagementTableViewManager,
        onRefreshComplete: @escaping (_ withAccounts: [TradeItLinkedBrokerAccount]?) -> Void
    )
}
