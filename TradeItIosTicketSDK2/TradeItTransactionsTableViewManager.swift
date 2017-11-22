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
    private static let HEADER_HEIGHT = CGFloat(30)
    private static let CELL_HEIGHT = CGFloat(65)
    private var transactionHistoryResultPresenter: TransactionHistoryResultPresenter?
    private var linkedBrokerAccount: TradeItLinkedBrokerAccount
    
    weak var delegate: TradeItTransactionsTableDelegate?
    
    init(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.linkedBrokerAccount = linkedBrokerAccount
    }
    
    func updateTransactionHistoryResult(_ transactionHistoryResult: TradeItTransactionsHistoryResult) {
        self.transactionHistoryResultPresenter = TransactionHistoryResultPresenter(transactionHistoryResult, accountBaseCurrency: self.linkedBrokerAccount.accountBaseCurrency)
        self.transactionsTable?.reloadData()
    }
    
    func initiateRefresh() {
        self.refreshControl?.beginRefreshing()
        self.delegate?.refreshRequested(
            onRefreshComplete: {
                self.refreshControl?.endRefreshing()
            }
        )
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TradeItTransactionsTableViewManager.CELL_HEIGHT
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TradeItTransactionsTableViewManager.CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.transactionHistoryResultPresenter?.header(forTableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TradeItTransactionsTableViewManager.HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionHistoryResultPresenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.transactionHistoryResultPresenter?.cell(forTableView: tableView, andRow: indexPath.row) ?? UITableViewCell()
    }
    
    // MARK: private
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

fileprivate class TransactionHistoryResultPresenter {

    private var transactions: [TradeItTransaction]
    private var numberOfDays: Int
    private var accountBaseCurrency: String

    init(_ transactionHistoryResult: TradeItTransactionsHistoryResult, accountBaseCurrency: String) {
        self.transactions = transactionHistoryResult.transactionHistoryDetailsList?.sorted{ ($0.date ?? "01/01/1970") > ($1.date ?? "01/01/1970") } ?? []
        self.accountBaseCurrency = accountBaseCurrency
        self.numberOfDays = transactionHistoryResult.numberOfDaysHistory.intValue
    }

    func numberOfRows() -> Int {
        return self.transactions.count
    }

    func cell(forTableView tableView: UITableView, andRow row: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TRANSACTION_CELL_ID") as? TradeItTransactionTableViewCell
            , let transaction = self.transactions[safe: row] else {
                return UITableViewCell()
        }

        cell.populate(withTransaction: transaction, andAccountBasecurrency: self.accountBaseCurrency)
        return cell
    }

    func header(forTableView tableView: UITableView) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TRANSACTION_HEADER_ID") as? TradeItTransactionTableViewHeader else {
            return UITableViewCell()
        }
        cell.populate(numberOfDays: self.numberOfDays)
        return cell
    }
}


protocol TradeItTransactionsTableDelegate: class {
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
}
