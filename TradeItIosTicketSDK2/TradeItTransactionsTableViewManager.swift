class TradeItTransactionsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    var transactionsTable: UITableView? {
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
    
    private var transactions: [TradeItTransaction] = []
    
    private let HEADER_HEIGHT = 36
    
    func updateTransactions(_ transactions: [TradeItTransaction]) {
        self.transactions = transactions
        self.transactionsTable?.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TRANSACTION_HEADER_ID") ?? UITableViewCell()
        let header = cell.contentView
        TradeItThemeConfigurator.configureTableHeader(header: header)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(HEADER_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TRANSACTION_CELL_ID") as? TradeItTransactionTableViewCell
            , let transaction = self.transactions[safe: indexPath.row] else {
                return UITableViewCell()
        }
        
        cell.populate(withTransaction: transaction)
        return cell
    }
    

}

protocol TradeItTransactionsTableDelegate: class {
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
}
