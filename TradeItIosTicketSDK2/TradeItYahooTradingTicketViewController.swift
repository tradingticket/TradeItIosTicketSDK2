import UIKit
import MBProgressHUD

class TradeItYahooTradingTicketViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource, TradeItYahooAccountSelectionViewControllerDelegate {
    @IBOutlet weak var tableView: TradeItYahooTradingTicketTableView!
    @IBOutlet weak var reviewOrderButton: UIButton!

    var alertManager = TradeItAlertManager()
    let viewProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var selectionViewController: TradeItSelectionViewController!
    var accountSelectionViewController: TradeItYahooAccountSelectionViewController!
    var order = TradeItOrder()
    public weak var delegate: TradeItYahooTradingTicketViewControllerDelegate?

    private var ticketRows = [TicketRow]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let selectionViewController = self.viewProvider.provideViewController(forStoryboardId: .yahooSelectionView) as? TradeItSelectionViewController else {
            assertionFailure("ERROR: Could not instantiate TradeItSelectionViewController from storyboard")
            return
        }

        guard let accountSelectionViewController = self.viewProvider.provideViewController(forStoryboardId: .yahooAccountSelectionView) as? TradeItYahooAccountSelectionViewController else {
            assertionFailure("ERROR: Could not instantiate TradeItYahooAccountSelectionViewController from storyboard")
            return
        }

        accountSelectionViewController.delegate = self

        self.selectionViewController = selectionViewController
        self.accountSelectionViewController = accountSelectionViewController

        self.setOrderDefaults()

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
        case .account:
            self.navigationController?.pushViewController(self.accountSelectionViewController, animated: true)
        case .orderType:
            self.selectionViewController.initialSelection = TradeItOrderPriceTypePresenter.labelFor(self.order.type)
            self.selectionViewController.selections = TradeItOrderPriceTypePresenter.labels()
            self.selectionViewController.onSelected = { (selection: String) in
                self.order.type = TradeItOrderPriceTypePresenter.enumFor(selection)
                _ = self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
        case .expiration:
            self.selectionViewController.initialSelection = TradeItOrderExpirationPresenter.labelFor(self.order.expiration)
            self.selectionViewController.selections = TradeItOrderExpirationPresenter.labels()
            self.selectionViewController.onSelected = { (selection: String) in
                self.order.expiration = TradeItOrderExpirationPresenter.enumFor(selection)
                _ = self.navigationController?.popViewController(animated: true)
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
        guard let linkedBroker = self.order.linkedBrokerAccount?.linkedBroker
            else { return }

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                activityView.label.text = "Reviewing Order"
                self.order.preview(
                    onSuccess: { previewOrderResult, placeOrderCallback in
                        activityView.hide(animated: true)
                        self.delegate?.orderSuccessfullyPreviewed(onTradingTicketViewController: self,
                                                                  withPreviewOrderResult: previewOrderResult,
                                                                  placeOrderCallback: placeOrderCallback)
                    }, onFailure: { error in
                        activityView.hide(animated: true)
                        // TODO: use self.alertManager.showRelinkError
                        self.alertManager.showError(error, onViewController: self)
                    }
                )
            }, onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            }, onFailure: { errorResult in
                activityView.hide(animated: true)
                // TODO: use self.alertManager.showRelinkError
                self.alertManager.showError(errorResult, onViewController: self)
            }
        )
    }

    // MARK: TradeItYahooAccountSelectionViewControllerDelegate

    func accountSelectionViewController(_ accountSelectionViewController: TradeItYahooAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.order.linkedBrokerAccount = linkedBrokerAccount
        self.selectedAccountChanged()
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: Private

    private func selectedAccountChanged() {
        self.order.linkedBrokerAccount?.linkedBroker?.authenticateIfNeeded(onSuccess: {
            if self.order.action == .buy {
                self.updateAccountOverview()
            } else {
                self.updateSharesOwned()
            }
        }, onSecurityQuestion: { securityQuestion, onAnswerSecurityQuestion, onCancelSecurityQuestion in
            self.alertManager.promptUserToAnswerSecurityQuestion(
                securityQuestion,
                onViewController: self,
                onAnswerSecurityQuestion: onAnswerSecurityQuestion,
                onCancelSecurityQuestion: onCancelSecurityQuestion
            )
        }, onFailure: { error in
            self.alertManager.showRelinkError(
                error,
                withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                onViewController: self,
                onFinished: self.selectedAccountChanged
            )
        })
    }

    private func updateAccountOverview() {
        self.order.linkedBrokerAccount?.getAccountOverview(onSuccess: { accountOverview in
            self.reload(row: .account)
        }, onFailure: { error in
            self.alertManager.showRelinkError(
                error,
                withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                onViewController: self,
                onFinished: self.selectedAccountChanged
            )
        })

    }

    private func updateSharesOwned() {
        self.order.linkedBrokerAccount?.getPositions(onSuccess: { positions in
            self.reload(row: .account)
        }, onFailure: { error in
            self.alertManager.showRelinkError(
                error,
                withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                onViewController: self,
                onFinished: self.selectedAccountChanged
            )
        })
    }

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
            self.reviewOrderButton.enable()
        } else {
            self.reviewOrderButton.disable()
        }
    }

    private func reloadTicket() {
        self.setTitle()
        self.setReviewButtonEnablement()
        self.selectedAccountChanged()

        var ticketRows: [TicketRow] = [
            .account,
            .orderType,
            .expiration,
            .quantity,
        ]

        if self.order.requiresLimitPrice() {
            ticketRows.append(.limitPrice)
        }

        if self.order.requiresStopPrice() {
            ticketRows.append(.stopPrice)
        }

        ticketRows.append(.estimatedCost)

        self.ticketRows = ticketRows
        
        self.tableView.reloadData()
    }

    private func reload(row: TicketRow) {
        guard let indexOfRow = self.ticketRows.index(of: row) else {
            return
        }

        let indexPath = IndexPath.init(row: indexOfRow, section: 0)
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
                    self.reload(row: .estimatedCost)
                    self.setReviewButtonEnablement()
                }
            )
        case .limitPrice:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.limitPrice,
                placeholderText: "Enter limit price",
                onValueUpdated: { newValue in
                    self.order.limitPrice = newValue
                    self.reload(row: .estimatedCost)
                    self.setReviewButtonEnablement()
                }
            )
        case .stopPrice:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.stopPrice,
                placeholderText: "Enter stop price",
                onValueUpdated: { newValue in
                    self.order.stopPrice = newValue
                    self.reload(row: .estimatedCost)
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
        case .account:
            guard let detailCell = cell as? TradeItSelectionDetailCellTableViewCell else { return cell }
            detailCell.configure(
                detailPrimaryText: self.order.linkedBrokerAccount?.getFormattedAccountName(),
                detailSecondaryText: accountSecondaryText()
            )
        }

        return cell
    }

    private func accountSecondaryText() -> String? {
        if self.order.action == .buy {
            return buyingPowerText()
        } else {
            return sharesOwnedText()
        }
    }

    private func buyingPowerText() -> String? {
        guard let buyingPower = self.order.linkedBrokerAccount?.balance?.buyingPower else { return nil }
        return "Buying Power: " + NumberFormatter.formatCurrency(
            buyingPower,
            currencyCode: TradeItPresenter.DEFAULT_CURRENCY_CODE
        )
    }

    private func sharesOwnedText() -> String? {
        guard let positions = self.order.linkedBrokerAccount?.positions, !positions.isEmpty else { return nil }

        let positionMatchingSymbol = positions.filter { portfolioPosition in
            TradeItPortfolioPositionPresenterFactory.forTradeItPortfolioPosition(portfolioPosition).getFormattedSymbol() == self.order.symbol
        }.first

        let sharesOwned = positionMatchingSymbol?.position?.quantity ?? 0
        return "Shares Owned: " + NumberFormatter.formatQuantity(sharesOwned)
    }

    enum TicketRow {
        case account
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
            case selectionDetail = "TRADING_TICKET_SELECTION_DETAIL_CELL_ID"
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
            case .account:
                cellReuseId = .selectionDetail
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
            case .account:
                return "Accounts"
            }
        }
    }
}

@objc protocol TradeItYahooTradingTicketViewControllerDelegate {
    func orderSuccessfullyPreviewed(
        onTradingTicketViewController tradingTicketViewController: TradeItYahooTradingTicketViewController,
        withPreviewOrderResult previewOrderResult: TradeItPreviewOrderResult,
        placeOrderCallback: @escaping TradeItPlaceOrderHandlers
    )
}
