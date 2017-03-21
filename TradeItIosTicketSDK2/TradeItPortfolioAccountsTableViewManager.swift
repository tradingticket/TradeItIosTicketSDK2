import UIKit

class TradeItPortfolioAccountsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokerSectionPresenters: [LinkedBrokerSectionPresenter] = []
    private var refreshControl: UIRefreshControl?
    private let NON_LINKED_BROKER_SECTIONS_COUNT = 1
    
    var accountsTable: UITableView? {
        get {
            return _table
        }

        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }
    }
    
    weak var delegate: TradeItPortfolioAccountsTableDelegate?
    
    func update(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker]) {
        self.linkedBrokerSectionPresenters = linkedBrokers.map { linkedBroker in
            return LinkedBrokerSectionPresenter(linkedBroker: linkedBroker)
        }
        self.accountsTable?.reloadData()
    }

    func initiateRefresh() {
        self.refreshControl?.beginRefreshing()
        self.delegate?.refreshRequested(
            onRefreshComplete: { linkedBrokers in
                self.update(withLinkedBrokers: linkedBrokers)
                self.refreshControl?.endRefreshing()
            }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linkedBrokerIndex = indexPath.section - NON_LINKED_BROKER_SECTIONS_COUNT
        guard let linkedBrokerPresenter = self.linkedBrokerSectionPresenters[safe: linkedBrokerIndex] else { return }

        if linkedBrokerPresenter.hasError() && indexPath.row == 0 {
            guard let error = linkedBrokerPresenter.linkedBroker.error else { return }

            if error.requiresRelink() {
                self.delegate?.relink(linkedBroker: linkedBrokerPresenter.linkedBroker)
            } else if error.requiresAuthentication() {
                self.delegate?.authenticate(linkedBroker: linkedBrokerPresenter.linkedBroker)
            } else {
                self.initiateRefresh()
            }
        } else {
            guard let account = linkedBrokerPresenter.accountFor(row: indexPath.row) else { return }
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount: account)
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let linkedBrokerIndex = indexPath.section - NON_LINKED_BROKER_SECTIONS_COUNT
        guard let linkedBrokerPresenter = self.linkedBrokerSectionPresenters[safe: linkedBrokerIndex] else { return nil }

        if linkedBrokerPresenter.hasError() && indexPath.row != 0 {
            return nil
        } else {
            return indexPath
        }
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + self.linkedBrokerSectionPresenters.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TABLE_HEADER")!
        if section == 0 {
            header.textLabel?.text = "Total Value"
        } else {
            header.textLabel?.text = self.linkedBrokerSectionPresenters[safe: section - 1]?.linkedBroker.brokerName
        }
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        } else {
            guard let linkedBrokerSectionPresenter = self.linkedBrokerSectionPresenters[safe: section - 1] else { return 0 }
            return linkedBrokerSectionPresenter.numberOfRows()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNTS_SUMMARY") ?? UITableViewCell()
                cell.textLabel?.text = NumberFormatter.formatCurrency(NSNumber(value: self.totalValue()), currencyCode: nil)
                cell.detailTextLabel?.text = "\(self.numberOfAccounts()) Combined Accounts"
                return cell
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Manage Accounts"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        } else {
            let linkedBrokerIndex = indexPath.section - NON_LINKED_BROKER_SECTIONS_COUNT
            guard let sectionPresenter = self.linkedBrokerSectionPresenters[safe: linkedBrokerIndex] else { return UITableViewCell() }
            return sectionPresenter.cellFor(tableView: tableView, andRow: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: Private

    private func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(
            self,
            action: #selector(initiateRefresh),
            for: UIControlEvents.valueChanged
        )
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
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
            guard let error = linkedBroker.error else { return UITableViewCell() }
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
        return linkedBroker.error != nil
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
    func relink(linkedBroker: TradeItLinkedBroker)
    func authenticate(linkedBroker: TradeItLinkedBroker)
    func refreshRequested(onRefreshComplete: @escaping ([TradeItLinkedBroker]) -> Void)
}
