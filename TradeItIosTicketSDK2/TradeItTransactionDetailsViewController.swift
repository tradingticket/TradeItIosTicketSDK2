import UIKit

class TradeItTransactionDetailsViewController: TradeItViewController, UITableViewDelegate, UITableViewDataSource {

    var transaction: TradeItTransaction?
    var accountBaseCurrency: String?

    @IBOutlet weak var transactionDetailTableView: UITableView!

    private var transactionDetailsRows = [TransactionDetailsRow]()
    private var presenter: TradeItTransactionPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let transaction = self.transaction else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItTransactionDetailsViewController loaded without setting transaction.")
        }
        guard let accountBaseCurrency = self.accountBaseCurrency else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItTransactionDetailsViewController loaded without setting accountBaseCurrency.")
        }
        self.transactionDetailTableView.delegate = self
        self.transactionDetailTableView.dataSource = self
        self.presenter = TradeItTransactionPresenter(transaction, currencyCode: accountBaseCurrency)
        self.title = self.presenter?.getTransactionTypeLabel()
        if self.presenter?.getTransactionDescriptionLabel() != "" {
            self.transactionDetailsRows.append(.description)
        }
        if self.presenter?.getTransactionActionLabel() != "" {
            self.transactionDetailsRows.append(.action)
        }
        if self.presenter?.getTransactionQuantityLabel() != "" {
            self.transactionDetailsRows.append(.quantity)
        }
        if self.presenter?.getTransactionSymbolLabel() != "" {
            self.transactionDetailsRows.append(.symbol)
        }
        if self.presenter?.getTransactionPriceLabel() != "" {
            self.transactionDetailsRows.append(.price)
        }
        if self.presenter?.getTransactionCommissionLabel() != "" {
            self.transactionDetailsRows.append(.commission)
        }
        if self.presenter?.getAmountLabel() != "" {
            self.transactionDetailsRows.append(.amount)
        }
        if self.presenter?.getTransactionDateLabel() != "" {
            self.transactionDetailsRows.append(.date)
        }
        if self.presenter?.getTransactionIdLabel() != "" {
            self.transactionDetailsRows.append(.id)
        }
        self.transactionDetailTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionDetailsRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_TRANSACTION_DETAILS_CELL_ID")
            , let transactionDetailsRow = self.transactionDetailsRows[safe: indexPath.row]
            , let presenter = self.presenter  else {
            return  UITableViewCell()
        }
        cell.textLabel?.text = transactionDetailsRow.getTitle()
        cell.detailTextLabel?.text = transactionDetailsRow.getValue(presenter: presenter)
        return cell
    }

}
