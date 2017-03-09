import UIKit

class TradeItPortfolioAccountsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    let PORTFOLIO_ACCOUNTS_HEADER_ID = "PORTFOLIO_ACCOUNTS_HEADER_ID"
    let PORTFOLIO_ACCOUNTS_CELL_ID = "PORTFOLIO_ACCOUNTS_CELL_ID"
    let PORTFOLIO_ERROR_CELL_ID = "PORTFOLIO_ERROR_CELL_ID"

    private var _table: UITableView?
    private var linkedBrokerSectionPresenters: [LinkedBrokerSectionPresenter] = []
    
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
    
    func updateAccounts(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker]) {
        self.linkedBrokerSectionPresenters = linkedBrokers.map({ linkedBroker in
            return LinkedBrokerSectionPresenter(linkedBroker: linkedBroker)
        })
        self.accountsTable?.reloadData()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let account = self.linkedBrokerSectionPresenters[safe: indexPath.section - 1]?.accountFor(row: indexPath.row) else { return }
        self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: account)
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + self.linkedBrokerSectionPresenters.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Total Value"
        } else {
            return self.linkedBrokerSectionPresenters[safe: section - 1]?.linkedBroker.brokerName
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            guard let linkedBrokerSectionPresenter = self.linkedBrokerSectionPresenters[safe: section - 1] else { return 0 }
            return linkedBrokerSectionPresenter.numberOfRows()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNTS_SUMMARY") ?? UITableViewCell()
            cell.textLabel?.text = NumberFormatter.formatCurrency(NSNumber(value: self.totalValue()), currencyCode: nil)
            cell.detailTextLabel?.text = "\(self.numberOfAccounts()) Combined Accounts"
            return cell
        } else {
            guard let sectionPresenter = self.linkedBrokerSectionPresenters[safe: indexPath.section - 1] else { return UITableViewCell() }
            return sectionPresenter.cellFor(tableView: tableView, andRow: indexPath.row)
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
        for sectionPresenter in linkedBrokerSectionPresenters {
            for account in sectionPresenter.linkedBroker.getEnabledAccounts() {
                if let balance = account.balance, let totalValue = balance.totalValue {
                    totalAccountsValue += totalValue.floatValue
                } else if let fxBalance = account.fxBalance, let totalValueUSD = fxBalance.totalValueUSD {
                    totalAccountsValue += totalValueUSD.floatValue
                }
            }
        }
        return totalAccountsValue
    }

    private func numberOfAccounts() -> Int {
        return linkedBrokerSectionPresenters.flatMap { sectionPresenter in
            return sectionPresenter.linkedBroker.getEnabledAccounts()
        }.count
    }
}

fileprivate class LinkedBrokerSectionPresenter {
    let linkedBroker: TradeItLinkedBroker

    init(linkedBroker: TradeItLinkedBroker) {
        self.linkedBroker = linkedBroker
    }

    func numberOfRows() -> Int {
        return self.linkedBroker.accounts.count + errorOffset()
    }

    func cellFor(tableView: UITableView, andRow row: Int) -> UITableViewCell {
        if row == 0 && hasError() {
            guard let error = linkedBroker.error else { return UITableViewCell() } // TODO: Wut?
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_LINKED_BROKER_ERROR") as! TradeItPortfolioLinkedBrokerErrorTableViewCell
            cell.populate(withError: error)
            return cell
        }

        guard let account = accountFor(row: row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNT") as! TradeItPortfolioAccountTableViewCell
        cell.populate(withAccount: account)
        return cell
    }

    func accountFor(row: Int) -> TradeItLinkedBrokerAccount? {
        return self.linkedBroker.accounts[safe: row - errorOffset()]
    }

    func hasError() -> Bool {
        guard let error = linkedBroker.error else { return false }
        return !error.requiresAuthentication()
    }

    func hasRelinkError() -> Bool {
        guard let error = linkedBroker.error else { return false }
        return error.requiresRelink()
    }

    func errorOffset() -> Int {
        if hasError() {
            return 1
        } else {
            return 0
        }
    }
}

protocol TradeItPortfolioAccountsTableDelegate: class {
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount)
}
