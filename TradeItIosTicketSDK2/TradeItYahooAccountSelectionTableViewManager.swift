import UIKit

class TradeItYahooAccountSelectionTableViewManager: TradeItYahooViewController, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokers: [TradeItLinkedBroker] = []
    private var refreshControl: UIRefreshControl?
    private let addAccountTableSectionIndex = 0
    internal weak var delegate: TradeItYahooAccountSelectionTableViewManagerDelegate?
    private var linkedBrokerSectionPresenters: [LinkedBrokerSectionPresenter] = []
    private var selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?

    
    var accountsTable: UITableView? {
        get {
            return _table
        }
        set(newTable) {
            if let newTable = newTable {
                newTable.tableFooterView = UIView()
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }
    }
    
    func updateLinkedBrokers(
        withLinkedBrokers linkedBrokers: [TradeItLinkedBroker],
        withSelectedLinkedBrokerAccount selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?
    ) {
        self.selectedLinkedBrokerAccount = selectedLinkedBrokerAccount
        self.linkedBrokers = linkedBrokers
        self.linkedBrokerSectionPresenters = linkedBrokers.map { linkedBroker in
            return LinkedBrokerSectionPresenter(
                linkedBroker: linkedBroker,
                selectedLinkedBrokerAccount: selectedLinkedBrokerAccount
            )
        }
        self.accountsTable?.reloadData()
    }

    func initiateRefresh(animated: Bool = true) {
        if animated {
            self.refreshControl?.beginRefreshing()
        }
        self.delegate?.refreshRequested(
            fromAccountSelectionTableViewManager: self,
            onRefreshComplete: { linkedBrokers in
                if let linkedBrokers = linkedBrokers  {
                    self.updateLinkedBrokers(
                        withLinkedBrokers: linkedBrokers,
                        withSelectedLinkedBrokerAccount:  self.selectedLinkedBrokerAccount
                    )
                }

                self.refreshControl?.endRefreshing()
            }
        )
    }

    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case addAccountTableSectionIndex:
            self.delegate?.addBrokerageAccountWasSelected()
        default:
            let linkedBrokerIndex = indexPath.section - 1
            guard let linkedBrokerPresenter = self.linkedBrokerSectionPresenters[safe: linkedBrokerIndex] else { return }

            if linkedBrokerPresenter.isAccountLinkDelayedError() {
                let cell = tableView.cellForRow(at: indexPath)
                let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityView.startAnimating()
                cell?.accessoryView = activityView
                guard let error = linkedBrokerPresenter.linkedBroker.error else { return }
                if error.requiresAuthentication() {
                    self.delegate?.authenticate(
                        linkedBroker: linkedBrokerPresenter.linkedBroker,
                        onFinished: {
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    )
                } else {
                    self.initiateRefresh()
                }
            } else {
                guard let selectedAccount = linkedBrokerPresenter.accountFor(row: indexPath.row) else { return }
                self.delegate?.linkedBrokerAccountWasSelected(selectedAccount)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.linkedBrokers.count + 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case addAccountTableSectionIndex:
            return ""
        default:
            let linkedBroker = self.linkedBrokers[section - 1]
            return linkedBroker.brokerName
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case addAccountTableSectionIndex:
            return 1
        default:
            let sectionPresenter = self.linkedBrokerSectionPresenters[section - 1]
            return sectionPresenter.numberOfRows()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case addAccountTableSectionIndex:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_ADD_CELL_ID") ?? UITableViewCell()
            return cell
        default:
            let sectionPresenter = self.linkedBrokerSectionPresenters[indexPath.section - 1]
            return sectionPresenter.cell(forTableView: tableView, andRow: indexPath.row)
        }
    }
    
    // MARK: Private
    
    func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self,
                                 action: #selector(refreshControlActivated),
                                 for: UIControlEvents.valueChanged)
        TradeItThemeConfigurator.configure(view: refreshControl)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
    
    func refreshControlActivated() {
        self.delegate?.refreshRequested(
            fromAccountSelectionTableViewManager: self,
            onRefreshComplete: { linkedBrokers in
                if let linkedBrokers = linkedBrokers {
                    self.updateLinkedBrokers(
                        withLinkedBrokers: linkedBrokers,
                        withSelectedLinkedBrokerAccount: self.selectedLinkedBrokerAccount
                    )
                }
                                            
                self.refreshControl?.endRefreshing()
            }
        )
    }
}

fileprivate class LinkedBrokerSectionPresenter {
    let linkedBroker: TradeItLinkedBroker
    let selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?
    
    init(
        linkedBroker: TradeItLinkedBroker,
         selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?
    ) {
        self.linkedBroker = linkedBroker
        self.selectedLinkedBrokerAccount = selectedLinkedBrokerAccount
    }
    
    func numberOfRows() -> Int {
        if self.isAccountLinkDelayedError() {
            return 1
        } else {
            return self.linkedBroker.getEnabledAccounts().count
        }
    }
    
    func cell(forTableView tableView: UITableView, andRow row: Int) -> UITableViewCell {
        if self.isAccountLinkDelayedError() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_ERROR_CELL_ID") as? TradeItLinkedBrokerErrorTableViewCell
            cell?.populate(withLinkedBroker: linkedBroker)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        } else {
            let linkedBrokerAccount = linkedBroker.getEnabledAccounts()[row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_CELL_ID") ?? UITableViewCell()
            
            let presenter = TradeItPortfolioBalanceEquityPresenter(linkedBrokerAccount)
            cell.textLabel?.text = linkedBrokerAccount.getFormattedAccountName()
            
            cell.detailTextLabel?.text = ""
            
            if let buyingPower = presenter.getFormattedBuyingPowerLabelWithTimestamp() {
                cell.detailTextLabel?.text = "Buying power: " + buyingPower
            }
            
            if self.selectedLinkedBrokerAccount?.accountNumber == linkedBrokerAccount.accountNumber
                && selectedLinkedBrokerAccount?.brokerName == linkedBrokerAccount.brokerName {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    func accountFor(row: Int) -> TradeItLinkedBrokerAccount? {
        return self.linkedBroker.getEnabledAccounts()[safe: row]
    }
    
    func isAccountLinkDelayedError() -> Bool {
        return self.linkedBroker.isAccountLinkDelayedError
    }
}

protocol TradeItYahooAccountSelectionTableViewManagerDelegate: class {
    func addBrokerageAccountWasSelected()
    func authenticate(linkedBroker: TradeItLinkedBroker, onFinished: @escaping () -> Void)
    func linkedBrokerAccountWasSelected(_ linkedBrokerAccount: TradeItLinkedBrokerAccount)
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItYahooAccountSelectionTableViewManager,
                          onRefreshComplete: @escaping ([TradeItLinkedBroker]?) -> Void)
}


