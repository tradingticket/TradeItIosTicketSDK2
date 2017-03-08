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
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = self.accountFor(indexPath: indexPath)
        self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: account)
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
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNT") as! TradeItPortfolioAccountTableViewCell
            let account = self.accountFor(indexPath: indexPath)
            cell.populate(withAccount: account)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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

    private func accountFor(indexPath: IndexPath) -> TradeItLinkedBrokerAccount {
        return self.linkedBrokers[indexPath.section - 1].accounts[indexPath.row]
    }
}

protocol TradeItPortfolioAccountsTableDelegate: class {
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount)
}
