import UIKit

class TradeItYahooTradingTicketViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: TradeItYahooTradingTicketTableView!
    @IBOutlet weak var reviewOrderButton: UIButton!

    let viewProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var selectionViewController: TradeItSelectionViewController!
    var order = TradeItOrder()
    public weak var delegate: TradeItYahooTradingTicketViewControllerDelegate?

    private var ticketRows = [TicketRow]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let selectionViewController = self.viewProvider.provideViewController(forStoryboardId: .yahooSelectionView) as? TradeItSelectionViewController else {
            assertionFailure("ERROR: Could not instantiate TradeItSelectionViewController from storyboard")
            return
        }

        self.selectionViewController = selectionViewController

        self.setOrderDefaults()
        self.reloadTicket()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.reloadTicket()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticketRow = self.ticketRows[indexPath.row]

        switch ticketRow {
        case .orderType:
            self.selectionViewController.initialSelection = TradeItOrderPriceTypePresenter.labelFor(self.order.type)
            self.selectionViewController.selections = TradeItOrderPriceTypePresenter.labels()
            self.selectionViewController.onSelected = { (selection: String) in
                self.order.type = TradeItOrderPriceTypePresenter.enumFor(selection)
                self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
        case .expiration:
            self.selectionViewController.initialSelection = TradeItOrderExpirationPresenter.labelFor(self.order.expiration)
            self.selectionViewController.selections = TradeItOrderExpirationPresenter.labels()
            self.selectionViewController.onSelected = { (selection: String) in
                self.order.expiration = TradeItOrderExpirationPresenter.enumFor(selection)
                self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
        default:
            return
        }
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
        print("=====> REVIEW ORDER BUTTON TAPPED: \(self.order)") //AKAKTRACE
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

    private func setOrderDefaults() {
        if self.order.action == .unknown {
            self.order.action = .buy
        }

        if self.order.expiration == .unknown {
            self.order.expiration = .goodForDay
        }
    }

    private func setReviewButtonEnablement() {
        if self.order.isValid() {
            self.reviewOrderButton.isEnabled = true
            self.reviewOrderButton.alpha = 1.0
        } else {
            self.reviewOrderButton.isEnabled = false
            self.reviewOrderButton.alpha = 0.5
        }
    }

    private func reloadTicket() {
        self.setTitle()
        self.setReviewButtonEnablement()

        var ticketRows: [TicketRow] = [
            .orderType,
            .expiration,
            .quantity,
        ]

        if [.limit, .stopLimit].contains(self.order.type) {
            ticketRows.append(.limitPrice)
        }

        if [.stopMarket, .stopLimit].contains(self.order.type) {
            ticketRows.append(.stopPrice)
        }

        ticketRows.append(.estimatedCost)

        self.ticketRows = ticketRows
        
        self.tableView.reloadData()
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
        cell.selectionStyle = .none

        switch ticketRow {
        case .quantity:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.quantity,
                placeholderText: "Enter shares",
                onValueUpdated: { newValue in
                    self.order.quantity = newValue
                    self.reloadEstimatedCostRow()
                    self.setReviewButtonEnablement()
                }
            )
        case .limitPrice:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.limitPrice,
                placeholderText: "Enter limit price",
                onValueUpdated: { newValue in
                    self.order.limitPrice = newValue
                    self.reloadEstimatedCostRow()
                    self.setReviewButtonEnablement()
                }
            )
        case .stopPrice:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.stopPrice,
                placeholderText: "Enter stop price",
                onValueUpdated: { newValue in
                    self.order.stopPrice = newValue
                    self.reloadEstimatedCostRow()
                    self.setReviewButtonEnablement()
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
        case .orderType:
            cell.detailTextLabel?.text = TradeItOrderPriceTypePresenter.labelFor(self.order.type)
        case .expiration:
            cell.detailTextLabel?.text = TradeItOrderExpirationPresenter.labelFor(self.order.expiration)
        }

        return cell
    }

    enum TicketRow {
        //    case account // Account
        case orderType
        case quantity
        case expiration
        case limitPrice
        case stopPrice
        //    case marketPrice // Market Price
        case estimatedCost

        private enum CellReuseId: String {
            case readOnly = "TRADING_TICKET_READ_ONLY_CELL_ID"
            case numericInput = "TRADING_TICKET_NUMERIC_INPUT_CELL_ID"
            case selection = "TRADING_TICKET_SELECTION_CELL_ID"
        }

        var cellReuseId: String {
            var cellReuseId: CellReuseId

            switch self {
            case .estimatedCost:
                cellReuseId = .readOnly
            case .quantity, .limitPrice, .stopPrice:
                cellReuseId = .numericInput
            case .orderType, .expiration:
                cellReuseId = .selection
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
            case .orderType:
                return "Order Type"
            case .expiration:
                return "Time in force"
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
