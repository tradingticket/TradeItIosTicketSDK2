import UIKit

class TradeItYahooTradingTicketViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reviewOrderButton: UIButton!

    var order = TradeItOrder()
    public weak var delegate: TradeItYahooTradingTicketViewControllerDelegate?

    private let ticketRows: [TicketRow] = [
        .quantity,
        .limitPrice,
        .stopPrice,
        .estimatedCost
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTitle()
        self.setTicketRows()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }

    private func setTicketRows() {
        var ticketRows: [TicketRow] = [
            .quantity,
            .limitPrice,
            .stopPrice,
            .estimatedCost
        ]

        self.ticketRows = ticketRows
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ticketRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.provideCell(rowIndex: indexPath.row)
    }

    // MARK: IBActions

    @IBAction func reviewOrderButtonTapped(_ sender: UIButton) {
        print("=====> REVIEW ORDER BUTTON TAPPED: \(self.order)")
    }

    // MARK: Private

    private func setTitle() {
        var title = "Trade"

        if self.order.action != TradeItOrderAction.unknown {
            title = TradeItOrderActionPresenter.labelFor(self.order.action)
        }

        if let symbol = self.order.symbol {
            title += " \(symbol)"
        }

        self.title = title
    }

    private func reloadEstimatedCostRow() {
        guard let indexOfEstimatedCost = self.ticketRows.index(of: .estimatedCost) else {
            return
        }

        let indexPath = IndexPath.init(row: indexOfEstimatedCost, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func provideCell(rowIndex: Int) -> UITableViewCell {
        let ticketRow = self.ticketRows[rowIndex]

        let cell = tableView.dequeueReusableCell(withIdentifier: ticketRow.cellReuseId) ?? UITableViewCell()
        cell.textLabel?.text = ticketRow.getTitle(forOrder: self.order)

        switch ticketRow {
        case .quantity:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.quantity,
                placeholderText: "Enter shares",
                onValueUpdated: { newValue in
                    print("=====> OLD SHARES: \(self.order.quantity)") //AKAKTRACE
                    print("=====> NEW SHARES: \(newValue)") //AKAKTRACE
                    self.order.quantity = newValue
                    self.reloadEstimatedCostRow()
                }
            )
        case .limitPrice:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.limitPrice,
                placeholderText: "Enter limit price",
                onValueUpdated: { newValue in
                    print("=====> OLD LIMIT: \(self.order.limitPrice)") //AKAKTRACE
                    print("=====> NEW LIMIT: \(newValue)") //AKAKTRACE
                    self.order.limitPrice = newValue
                    self.reloadEstimatedCostRow()
                }
            )
        case .stopPrice:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.stopPrice,
                placeholderText: "Enter stop price",
                onValueUpdated: { newValue in
                    print("=====> OLD SHARES: \(self.order.stopPrice)") //AKAKTRACE
                    print("=====> NEW SHARES: \(newValue)") //AKAKTRACE
                    self.order.stopPrice = newValue
                    self.reloadEstimatedCostRow()
                }
            )
        case .estimatedCost:
            var estimateChangeText = "N/A"

            if let estimatedChange = order.estimatedChange() {
                estimateChangeText = NumberFormatter.formatCurrency(
                    estimatedChange,
                    currencyCode: TradeItPresenter.DEFAULT_CURRENCY_CODE)
            }

            cell.detailTextLabel?.text = estimateChangeText
        }

        return cell
    }

    enum TicketRow {
        //    case account // Account
        //    case orderType // Order Type
        case quantity // Shares
        //    case duration // Time in force
        case limitPrice // Limit
        case stopPrice // Stop
        //    case marketPrice // Market Price
        case estimatedCost // Estimated Cost/Proceeds

        private enum CellReuseId: String {
            case readOnly = "TRADING_TICKET_READ_ONLY_CELL_ID"
            case numericInput = "TRADING_TICKET_NUMERIC_INPUT_CELL_ID"
        }

        var cellReuseId: String {
            var cellReuseId: CellReuseId

            switch self {
            case .estimatedCost:
                cellReuseId = .readOnly
            case .quantity, .limitPrice, .stopPrice:
                cellReuseId = .numericInput
                //        case .orderType:
                //        // Order Type
                //        case .duration:
                //        // Time in force
                //        case .marketPrice:
                //        // Market Price
                //        case .account:
                //        // Account
            }

            return cellReuseId.rawValue
        }

        func getTitle(forOrder order: TradeItOrder) -> String {
            switch self {
            case .estimatedCost:
                let sellActions: [TradeItOrderAction] = [.sell, .sellShort]
                let title = "Estimated \(sellActions.contains(order.action) ? "Proceeds" : "Cost")"
                return title
            case .quantity:
                return "Shares"
            case .limitPrice:
                return "Limit"
            case .stopPrice:
                return "Stop"
                //        case .orderType:
                //        // Order Type
                //        case .duration:
                //        // Time in force
                //        case .marketPrice:
                //        // Market Price
                //        case .account:
                //        // Account
            }
        }
    }
}

@objc protocol TradeItYahooTradingTicketViewControllerDelegate {
    
}
