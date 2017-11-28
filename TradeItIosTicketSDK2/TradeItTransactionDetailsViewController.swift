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
        let presenter = TradeItTransactionPresenter(transaction, currencyCode: accountBaseCurrency)
        self.presenter = presenter
        self.title = presenter.getTransactionTypeLabel()

        self.transactionDetailsRows = [
            .description,
            .action,
            .quantity,
            .symbol,
            .price,
            .commission,
            .amount,
            .date,
            .id
        ].filter { $0.getValue(presenter: presenter) != "" }

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
