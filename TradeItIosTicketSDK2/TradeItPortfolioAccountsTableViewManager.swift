import UIKit

class TradeItPortfolioAccountsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    let PORTFOLIO_ACCOUNTS_HEADER_ID = "PORTFOLIO_ACCOUNTS_HEADER_ID"
    let PORTFOLIO_ACCOUNTS_CELL_ID = "PORTFOLIO_ACCOUNTS_CELL_ID"
    let PORTFOLIO_ERROR_CELL_ID = "PORTFOLIO_ERROR_CELL_ID"

    fileprivate var _table: UITableView?
    fileprivate var accounts: [TradeItLinkedBrokerAccount] = []
    fileprivate var linkedBrokersInError: [TradeItLinkedBroker] = []
    
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
            let firstIndexPath = IndexPath(row: 0, section: 0)
            self.accountsTable?.selectRow(at: firstIndexPath, animated: true, scrollPosition: .top)
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: self.accounts[0])
        }
        else if self.linkedBrokersInError.count > 0 {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            self.accountsTable?.selectRow(at: firstIndexPath, animated: true, scrollPosition: .top)
            self.delegate?.linkedBrokerInErrorWasSelected(selectedBrokerInError: self.linkedBrokersInError[0])
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row < self.accounts.count {
            let selectedAccount = self.accounts[(indexPath as NSIndexPath).row]
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: selectedAccount)
        }
        else {
            let linkedBrokerInError = self.linkedBrokersInError[(indexPath as NSIndexPath).row - self.accounts.count]
            self.delegate?.linkedBrokerInErrorWasSelected(selectedBrokerInError: linkedBrokerInError)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count + self.linkedBrokersInError.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ACCOUNTS_HEADER_ID)
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell :UITableViewCell!
        
        if (indexPath as NSIndexPath).row < self.accounts.count {
            let accountCell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ACCOUNTS_CELL_ID) as! TradeItPortfolioAccountsTableViewCell
            let account = accounts[(indexPath as NSIndexPath).row]
            accountCell.populate(withAccount: account)
            cell = accountCell
        }
        else {
            let errorCell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ERROR_CELL_ID) as! TradeItPortfolioErrorTableViewCell
            let linkedBrokerInError = self.linkedBrokersInError[(indexPath as NSIndexPath).row - self.accounts.count]
            errorCell.populate(withLinkedBroker: linkedBrokerInError)
            cell = errorCell
        }
        
        return cell
    }
}

protocol TradeItPortfolioAccountsTableDelegate: class {
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount)
    func linkedBrokerInErrorWasSelected(selectedBrokerInError: TradeItLinkedBroker)
}
