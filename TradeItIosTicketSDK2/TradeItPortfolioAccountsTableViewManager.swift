import UIKit

class TradeItPortfolioAccountsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    let PORTFOLIO_ACCOUNTS_HEADER_ID = "PORTFOLIO_ACCOUNTS_HEADER_ID"
    let PORTFOLIO_ACCOUNTS_CELL_ID = "PORTFOLIO_ACCOUNTS_CELL_ID"
    let PORTFOLIO_ERROR_CELL_ID = "PORTFOLIO_ERROR_CELL_ID"

    private var _table: UITableView?
    private var accounts: [TradeItLinkedBrokerAccount] = []
    private var linkedBrokersInError: [TradeItLinkedBroker] = []
    
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
    
    weak var delegate: TradeItPortfolioAccountsTableDelegate?
    
    func updateAccounts(withAccounts accounts: [TradeItLinkedBrokerAccount], withLinkedBrokersInError linkedBrokersInError: [TradeItLinkedBroker]) {
        self.accounts = accounts
        self.linkedBrokersInError = linkedBrokersInError
        self.accountsTable?.reloadData()

        if accounts.count > 0 {
            let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.accountsTable?.selectRowAtIndexPath(firstIndexPath, animated: true, scrollPosition: .Top)
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: self.accounts[0])
        }
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.accounts.count {
            let selectedAccount = self.accounts[indexPath.row]
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: selectedAccount)
        }
        else {
            let linkedBrokerInError = self.linkedBrokersInError[indexPath.row - self.accounts.count]
            self.delegate?.linkedBrokerInErrorWasSelected(selectedBrokerInError: linkedBrokerInError)
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count + self.linkedBrokersInError.count
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(PORTFOLIO_ACCOUNTS_HEADER_ID)
        return cell
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell :UITableViewCell!
        
        if indexPath.row < self.accounts.count {
            let accountCell = tableView.dequeueReusableCellWithIdentifier(PORTFOLIO_ACCOUNTS_CELL_ID) as! TradeItPortfolioAccountsTableViewCell
            let account = accounts[indexPath.row]
            accountCell.populate(withAccount: account)
            cell = accountCell
        }
        else {
            let errorCell = tableView.dequeueReusableCellWithIdentifier(PORTFOLIO_ERROR_CELL_ID) as! TradeItPortfolioErrorTableViewCell
            let linkedBrokerInError = self.linkedBrokersInError[indexPath.row - self.accounts.count]
            errorCell.populate(withLinkedBroker: linkedBrokerInError)
            cell = errorCell
        }
        
        return cell
    }
}

protocol TradeItPortfolioAccountsTableDelegate: class {
    func linkedBrokerAccountWasSelected(selectedAccount selectedAccount: TradeItLinkedBrokerAccount)
    func linkedBrokerInErrorWasSelected(selectedBrokerInError selectedBrokerInError: TradeItLinkedBroker)
}
