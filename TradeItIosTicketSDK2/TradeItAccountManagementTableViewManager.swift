import UIKit

class TradeItAccountManagementTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {

    private var _table: UITableView?
    private var linkedBrokerAccounts: [TradeItLinkedBrokerAccount] = []
    var accountsTable: UITableView? {
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

    func updateAccounts(withAccounts linkedBrokerAccounts: [TradeItLinkedBrokerAccount]) {
        self.linkedBrokerAccounts = linkedBrokerAccounts
        self.accountsTable?.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkedBrokerAccounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ACCOUNTS_MANAGEMENT_CELL_ID") as! TradeItAccountManagementTableViewCell
        cell.populate(self.linkedBrokerAccounts[indexPath.row])
        return cell
    }

}
