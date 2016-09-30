import UIKit

class TradeItAccountManagementTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokerAccounts: [TradeItLinkedBrokerAccount] = []
    private var refreshControl: UIRefreshControl?
    var delegate: TradeItAccountManagementTableViewManagerDelegate?

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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkedBrokerAccounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ACCOUNT_MANAGEMENT_CELL_ID") as! TradeItAccountManagementTableViewCell
        cell.populate(self.linkedBrokerAccounts[indexPath.row])
        return cell
    }

    // MARK: Private

    func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self,
                                 action: #selector(refreshControlActivated),
                                 forControlEvents: UIControlEvents.ValueChanged)
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

protocol TradeItAccountManagementTableViewManagerDelegate {
    func refreshRequested(fromAccountManagementTableViewManager manager: TradeItAccountManagementTableViewManager,
                                                                onRefreshComplete: (withAccounts: [TradeItLinkedBrokerAccount]?) -> Void)
}
