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
    
    func updateAccounts(withAccounts accounts: [TradeItLinkedBrokerAccount],
                        withLinkedBrokersInError linkedBrokersInError: [TradeItLinkedBroker],
                        withSelectedAccount selectedAccount: TradeItLinkedBrokerAccount?) {
        self.accounts = accounts
        self.linkedBrokersInError = linkedBrokersInError
        self.accountsTable?.reloadData()

        if accounts.count > 0 {
            let selectedAccount = selectedAccount ?? self.accounts[0]
            let selectedAccountIndex = self.accounts.index(where: {$0.accountNumber == selectedAccount.accountNumber && $0.brokerName == selectedAccount.brokerName}) ?? 0
            let selectedIndexPath = IndexPath(row: selectedAccountIndex, section: 0)
            self.accountsTable?.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: selectedAccount)
        } else if self.linkedBrokersInError.count > 0 {
            let selectedIndexPath = IndexPath(row: 0, section: 0)
            self.accountsTable?.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
            self.delegate?.linkedBrokerInErrorWasSelected(selectedBrokerInError: self.linkedBrokersInError[0])
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.accounts.count {
            let selectedAccount = self.accounts[indexPath.row]
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: selectedAccount)
        } else {
            let linkedBrokerInError = self.linkedBrokersInError[indexPath.row - self.accounts.count]
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
        TradeItThemeConfigurator.configureTableHeader(header: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.row < self.accounts.count {
            let accountCell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ACCOUNTS_CELL_ID) as! TradeItPortfolioAccountsTableViewCell
            let account = accounts[indexPath.row]
            accountCell.populate(withAccount: account)
            cell = accountCell
        } else {
            let errorCell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ERROR_CELL_ID) as! TradeItPortfolioErrorTableViewCell
            let linkedBrokerInError = self.linkedBrokersInError[indexPath.row - self.accounts.count]
            errorCell.populate(withLinkedBroker: linkedBrokerInError)
            cell = errorCell
        }

        TradeItThemeConfigurator.configureTableCell(cell: cell)
        
        return cell
    }
}

protocol TradeItPortfolioAccountsTableDelegate: class {
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount)
    func linkedBrokerInErrorWasSelected(selectedBrokerInError: TradeItLinkedBroker)
}
