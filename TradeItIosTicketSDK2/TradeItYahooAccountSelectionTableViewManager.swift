import UIKit

class TradeItYahooAccountSelectionTableViewManager: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokers: [TradeItLinkedBroker] = []
    private var refreshControl: UIRefreshControl?
    internal weak var delegate: TradeItYahooAccountSelectionTableViewManagerDelegate?
    
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
    
    func updateLinkedBrokers(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker]) {
        self.linkedBrokers = linkedBrokers
        self.accountsTable?.reloadData()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case addAccountTableSectionIndex:
            self.delegate?.addBrokerageAccountWasSelected()
        default:
            let linkedBroker = self.linkedBrokers[indexPath.section - 1]
            let selectedAccount = linkedBroker.getEnabledAccounts()[indexPath.row]
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount)
        }
    }
    
    // MARK: UITableViewDataSource
    
    private let addAccountTableSectionIndex = 0
    
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
            var numberOfLinkedAccounts = 0
            
            if self.linkedBrokers.count > 0 {
                let linkedBroker = self.linkedBrokers[section - 1]
                numberOfLinkedAccounts = linkedBroker.getEnabledAccounts().count
            }
            
            return numberOfLinkedAccounts
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case addAccountTableSectionIndex:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_ADD_CELL_ID") ?? UITableViewCell()
            return cell
        default:
            let linkedBroker = self.linkedBrokers[indexPath.section - 1]
            let linkedBrokerAccount = linkedBroker.getEnabledAccounts()[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_CELL_ID") ?? UITableViewCell()

            let presenter = TradeItPortfolioBalanceEquityPresenter(linkedBrokerAccount)
            cell.textLabel?.text = linkedBrokerAccount.getFormattedAccountName()

            cell.detailTextLabel?.text = ""

            if let buyingPower = presenter.getFormattedBuyingPowerLabelWithTimestamp() {
                cell.detailTextLabel?.text = "Buying power: " + buyingPower
            }
            return cell
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
        self.delegate?.refreshRequested(fromAccountSelectionTableViewManager: self,
                                        onRefreshComplete: { linkedBrokers in
                                            if let linkedBrokers = linkedBrokers {
                                                self.updateLinkedBrokers(withLinkedBrokers: linkedBrokers)
                                            }
                                            
                                            self.refreshControl?.endRefreshing()
        })
    }
}

protocol TradeItYahooAccountSelectionTableViewManagerDelegate: class {
    func addBrokerageAccountWasSelected()
    func linkedBrokerAccountWasSelected(_ linkedBrokerAccount: TradeItLinkedBrokerAccount)
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItYahooAccountSelectionTableViewManager,
                          onRefreshComplete: @escaping ([TradeItLinkedBroker]?) -> Void)
}


