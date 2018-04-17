class TradeItTransactionsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var refreshControl: UIRefreshControl?
    var transactionsTable: UITableView? {
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
    private static let HEADER_HEIGHT = CGFloat(40)
    private static let CELL_HEIGHT = CGFloat(65)
    var transactionHistoryResultPresenter: TransactionHistoryResultPresenter?
    private var linkedBrokerAccount: TradeItLinkedBrokerAccount
    private var noResultsBackgroundView: UIView
    weak var delegate: TradeItTransactionsTableDelegate?
    
    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, noResultsBackgroundView: UIView) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.noResultsBackgroundView = noResultsBackgroundView
    }
    
    func updateTransactionHistoryResult(_ transactionHistoryResult: TradeItTransactionsHistoryResult) {
        self.transactionHistoryResultPresenter = TransactionHistoryResultPresenter(transactionHistoryResult, linkedBrokerAccount: self.linkedBrokerAccount)
        if let transactions = transactionHistoryResult.transactionHistoryDetailsList, !transactions.isEmpty {
            self.transactionsTable?.backgroundView =  nil
        } else {
            self.transactionsTable?.backgroundView = noResultsBackgroundView
        }
        self.transactionsTable?.reloadData()
    }

    func filterTransactionHistoryResult(filterType: TransactionFilterType) {
        self.transactionHistoryResultPresenter?.filterTransactions(filterType: filterType)
        self.transactionsTable?.reloadData()
    }
    
    @objc func initiateRefresh() {
        self.refreshControl?.beginRefreshing()
        self.delegate?.refreshRequested(
            onRefreshComplete: {
                self.refreshControl?.endRefreshing()
            }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let transaction = self.transactionHistoryResultPresenter?.transactionsFiltered[safe: indexPath.row] else {
            return
        }
        self.delegate?.transactionWasSelected(transaction)
    }

    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let transactions = self.transactionHistoryResultPresenter?.transactionsFiltered, transactions.count > 0 else {
            return 0
        }
        return 2
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TradeItTransactionsTableViewManager.CELL_HEIGHT
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TradeItTransactionsTableViewManager.CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.transactionHistoryResultPresenter?.header(forTableView: tableView, isAccountInfoSection: isAccountInfoSection(section))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TradeItTransactionsTableViewManager.HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isAccountInfoSection(section) {
            return 0
        }

        return self.transactionHistoryResultPresenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAccountInfoSection(indexPath.section) {
            return UITableViewCell()
        } else {
            return self.transactionHistoryResultPresenter?.cell(forTableView: tableView, andRow: indexPath.row) ?? UITableViewCell()
        }
    }
    
    // MARK: private
    private func isAccountInfoSection(_ section: Int) -> Bool {
        return section == 0
    }

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

}

class TransactionHistoryResultPresenter {

    private var transactions: [TradeItTransaction]
    var transactionsFiltered: [TradeItTransaction]
    private var numberOfDays: Int
    private var filterType: TransactionFilterType = TransactionFilterType.ALL_TRANSACTIONS
    private let linkedBrokerAccount: TradeItLinkedBrokerAccount

    init(_ transactionHistoryResult: TradeItTransactionsHistoryResult, linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.transactions = transactionHistoryResult.transactionHistoryDetailsList?.sorted{ ($0.date ?? "01/01/1970") > ($1.date ?? "01/01/1970") } ?? []
        self.transactionsFiltered = self.transactions
        self.linkedBrokerAccount = linkedBrokerAccount
        self.numberOfDays = transactionHistoryResult.numberOfDaysHistory.intValue
    }

    func numberOfRows() -> Int {
        return self.transactionsFiltered.count
    }

    func cell(forTableView tableView: UITableView, andRow row: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TRANSACTION_CELL_ID") as? TradeItTransactionTableViewCell
            , let transaction = self.transactionsFiltered[safe: row] else {
                return UITableViewCell()
        }
        cell.populate(withTransaction: transaction, andAccountBasecurrency: getAccountBaseCurrency())
        return cell
    }

    func header(forTableView tableView: UITableView, isAccountInfoSection: Bool) -> UIView? {
        if isAccountInfoSection {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BRANDED_ACCOUNT_NAME_CELL_ID") as? TradeItPreviewBrandedAccountNameCell else {
                return UITableViewCell()
            }
            cell.populate(linkedBroker: linkedBrokerAccount)
            cell.backgroundColor = nil

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TRANSACTION_HEADER_ID") as? TradeItTransactionTableViewHeader else {
                return UITableViewCell()
            }
            cell.populate(numberOfDays: self.numberOfDays, filterType: self.filterType)
            return cell
        }
    }

    func filterTransactions(filterType: TransactionFilterType) {
        self.filterType = filterType
        self.transactionsFiltered = getTransactions(forFilterType: filterType)
    }
    func numberOfTransactions(forFilterType filterType: TransactionFilterType) -> Int {
        return getTransactions(forFilterType: filterType).count
    }

    private func getTransactions(forFilterType filterType: TransactionFilterType) -> [TradeItTransaction]{
        return self.transactions.filter {
            TradeItTransactionPresenter($0, currencyCode: getAccountBaseCurrency()).belongsToFilter(filter: filterType)
        }
    }

    private func getAccountBaseCurrency() -> String {
        return linkedBrokerAccount.accountBaseCurrency
    }
}


protocol TradeItTransactionsTableDelegate: class {
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
    func transactionWasSelected(_ transaction: TradeItTransaction)
}
