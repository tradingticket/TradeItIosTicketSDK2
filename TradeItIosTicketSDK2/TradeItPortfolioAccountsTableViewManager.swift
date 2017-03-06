import UIKit

class TradeItPortfolioAccountsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    let PORTFOLIO_ACCOUNTS_HEADER_ID = "PORTFOLIO_ACCOUNTS_HEADER_ID"
    let PORTFOLIO_ACCOUNTS_CELL_ID = "PORTFOLIO_ACCOUNTS_CELL_ID"
    let PORTFOLIO_ERROR_CELL_ID = "PORTFOLIO_ERROR_CELL_ID"

    private var _table: UITableView?
    private var linkedBrokers: [TradeItLinkedBroker] = []
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
    
    func updateAccounts(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker],
                        withLinkedBrokersInError linkedBrokersInError: [TradeItLinkedBroker],
                        withSelectedAccount selectedAccount: TradeItLinkedBrokerAccount?) {
        self.linkedBrokers = linkedBrokers
        self.linkedBrokersInError = linkedBrokersInError
        self.accountsTable?.reloadData()

//        if accounts.count > 0 {
//            let selectedAccount = selectedAccount ?? self.accounts[0]
//            let selectedAccountIndex = self.accounts.index(where: {$0.accountNumber == selectedAccount.accountNumber && $0.brokerName == selectedAccount.brokerName}) ?? 0
//            let selectedIndexPath = IndexPath(row: selectedAccountIndex, section: 0)
//            self.accountsTable?.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
//        } else if self.linkedBrokersInError.count > 0 {
//            let selectedIndexPath = IndexPath(row: 0, section: 0)
//            self.accountsTable?.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
//        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row < self.accounts.count {
//            let selectedAccount = self.accounts[indexPath.row]
//            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: selectedAccount)
//        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + self.linkedBrokers.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Total Value"
        } else {
            return self.linkedBrokers[section - 1].brokerName
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return self.linkedBrokers[section - 1].accounts.count
        }
    }

//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ACCOUNTS_HEADER_ID)
//        TradeItThemeConfigurator.configureTableHeader(header: cell)
//        return cell
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNTS_SUMMARY") ?? UITableViewCell()
            cell.textLabel?.text = NumberFormatter.formatCurrency(NSNumber(value: self.totalValue()), currencyCode: nil)
            cell.detailTextLabel?.text = "\(self.numberOfAccounts()) Combined Accounts"
//            cell.textLabel?.text = "DUMMY"
//            cell.detailTextLabel?.text = "TEST"

            return cell

        }
        return UITableViewCell()
//        var cell: UITableViewCell!
//        
//        if indexPath.row < self.accounts.count {
//            let accountCell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ACCOUNTS_CELL_ID) as! TradeItPortfolioAccountsTableViewCell
//            let account = accounts[indexPath.row]
//            accountCell.populate(withAccount: account)
//            cell = accountCell
//        } else {
//            let errorCell = tableView.dequeueReusableCell(withIdentifier: PORTFOLIO_ERROR_CELL_ID) as! TradeItPortfolioErrorTableViewCell
//            let linkedBrokerInError = self.linkedBrokersInError[indexPath.row - self.accounts.count]
//            errorCell.populate(withLinkedBroker: linkedBrokerInError)
//            cell = errorCell
//        }
//
//        return cell
    }

    private func totalValue() -> Float {
        var totalAccountsValue: Float = 0
        for linkedBroker in linkedBrokers {
            for account in linkedBroker.getEnabledAccounts() {
                if let balance = account.balance, let totalValue = balance.totalValue {
                    totalAccountsValue += totalValue.floatValue
                } else if let fxBalance = account.fxBalance, let totalValueUSD = fxBalance.totalValueUSD {
                    totalAccountsValue += totalValueUSD.floatValue
                }
            }
        }
        // TODO: CurrencyCode here should not be nil. Currency could be set per position or per account, so an aggregate makes no sense unless we convert it all to a single currency.
        return totalAccountsValue
//        self.totalValueLabel.text = NumberFormatter.formatCurrency(NSNumber(value: totalAccountsValue), currencyCode: nil)
    }

    private func numberOfAccounts() -> Int {
        return linkedBrokers.flatMap { linkedBroker in
            return linkedBroker.getEnabledAccounts()
        }.count
    }
}

protocol TradeItPortfolioAccountsTableDelegate: class {
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount)
}
