import UIKit

class TradeItPortfolioAccountsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    let PORTFOLIO_ACCOUNT_HEADER_ID = "PORTFOLIO_ACCOUNTS_HEADER_ID"
    let PORTFOLIO_ACCOUNT_CELL_ID = "PORTFOLIO_ACCOUNTS_CELL_ID"

    private var _table: UITableView?
    private var accounts: [TradeItLinkedBrokerAccount] = []
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

    func updateAccounts(withAccounts accounts: [TradeItLinkedBrokerAccount]) {
        self.accounts = accounts
        self.accountsTable?.reloadData()
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(PORTFOLIO_ACCOUNT_HEADER_ID)

        return cell
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PORTFOLIO_ACCOUNT_CELL_ID) as! TradeItPortfolioAccountsTableViewCell

        let account = accounts[indexPath.row]
        cell.populate(withAccount: account)

        return cell
    }
}