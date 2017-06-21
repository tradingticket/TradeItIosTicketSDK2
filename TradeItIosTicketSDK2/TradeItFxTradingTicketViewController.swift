import UIKit
import MBProgressHUD

class TradeItFxTradingTicketViewController: TradeItViewController, UITableViewDataSource, UITableViewDelegate, TradeItAccountSelectionViewControllerDelegate {
    @IBOutlet weak var tableView: TradeItDismissableKeyboardTableView!
    @IBOutlet weak var placeOrderButton: UIButton!

    public weak var delegate: TradeItFxTradingTicketViewControllerDelegate?

    internal var order = TradeItFxOrder()

    private var alertManager = TradeItAlertManager()
    private let viewProvider = TradeItViewControllerProvider()
    private var selectionViewController: TradeItSelectionViewController!
    private var accountSelectionViewController: TradeItAccountSelectionViewController!
    private let marketDataService = TradeItSDK.marketDataService
    private var quotePresenter: TradeItQuotePresenter?

    private var ticketRows = [TicketRow]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let selectionViewController = self.viewProvider.provideViewController(forStoryboardId: .tradingSelectionView) as? TradeItSelectionViewController else {
            assertionFailure("ERROR: Could not instantiate TradeItSelectionViewController from storyboard")
            return
        }
        self.selectionViewController = selectionViewController

        guard let accountSelectionViewController = self.viewProvider.provideViewController(forStoryboardId: .accountSelectionView) as? TradeItAccountSelectionViewController else {
            assertionFailure("ERROR: Could not instantiate TradeItAccountSelectionViewController from storyboard")
            return
        }
        accountSelectionViewController.delegate = self
        self.accountSelectionViewController = accountSelectionViewController

        self.setOrderDefaults()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()

        TicketRow.registerNibCells(forTableView: self.tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.reloadTicket()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticketRow = self.ticketRows[indexPath.row]

        switch ticketRow {
        case .symbol:
            self.selectionViewController.initialSelection = self.order.symbol
            self.selectionViewController.selections = [
                "USD/AUD",
                "USD/JPY"
            ]
            self.selectionViewController.onSelected = { selection in
                self.order.symbol = selection
                _ = self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
        case .account:
            self.navigationController?.pushViewController(self.accountSelectionViewController, animated: true)
//        case .orderAction:
//            self.selectionViewController.initialSelection = TradeItOrderActionPresenter.labelFor(self.order.action)
//            self.selectionViewController.selections = TradeItOrderActionPresenter.labels()
//            self.selectionViewController.onSelected = { (selection: String) in
//                self.order.action = TradeItOrderActionPresenter.enumFor(selection)
//                _ = self.navigationController?.popViewController(animated: true)
//            }
//
//            self.navigationController?.pushViewController(selectionViewController, animated: true)
//        case .orderType:
//            self.selectionViewController.initialSelection = TradeItOrderPriceTypePresenter.labelFor(self.order.type)
//            self.selectionViewController.selections = TradeItOrderPriceTypePresenter.labels()
//            self.selectionViewController.onSelected = { (selection: String) in
//                self.order.type = TradeItOrderPriceTypePresenter.enumFor(selection)
//                _ = self.navigationController?.popViewController(animated: true)
//            }
//
//            self.navigationController?.pushViewController(selectionViewController, animated: true)
//        case .expiration:
//            self.selectionViewController.initialSelection = TradeItOrderExpirationPresenter.labelFor(self.order.expiration)
//            self.selectionViewController.selections = TradeItOrderExpirationPresenter.labels()
//            self.selectionViewController.onSelected = { (selection: String) in
//                self.order.expiration = TradeItOrderExpirationPresenter.enumFor(selection)
//                _ = self.navigationController?.popViewController(animated: true)
//            }
//
//            self.navigationController?.pushViewController(selectionViewController, animated: true)
        default:
            return
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        struct StaticVars {
            static var rowHeights = [String:CGFloat]()
        }

        let ticketRow = self.ticketRows[indexPath.row]

        guard let height = StaticVars.rowHeights[ticketRow.cellReuseId] else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ticketRow.cellReuseId)
            let height = cell?.bounds.size.height ?? tableView.rowHeight
            StaticVars.rowHeights[ticketRow.cellReuseId] = height
            return height
        }

        return height
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ticketRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.provideCell(rowIndex: indexPath.row)
    }

    // MARK: IBActions

    @IBAction func placeOrderButtonTapped(_ sender: UIButton) {
        guard let linkedBroker = self.order.linkedBrokerAccount?.linkedBroker
            else { return }

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                activityView.label.text = "Placing order"
                self.order.place(
                    onSuccess: { placeOrderResult in
                        activityView.hide(animated: true)

                        self.delegate?.orderSuccessfullyPlaced(
                            onFxTradingTicketViewController: self,
                            withPlaceOrderResult: placeOrderResult
                        )
                    },
                    onFailure: { errorResult in
                        activityView.hide(animated: true)
                        self.alertManager.showAlertWithAction(
                            error: errorResult,
                            withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                            onViewController: self
                        )
                    }
                )
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { errorResult in
                activityView.hide(animated: true)
                self.alertManager.showAlertWithAction(
                    error: errorResult,
                    withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                    onViewController: self
                )
            }
        )
    }

    // MARK: TradeItAccountSelectionViewControllerDelegate

    func accountSelectionViewController(
        _ accountSelectionViewController: TradeItAccountSelectionViewController,
        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount
    ) {
        self.order.linkedBrokerAccount = linkedBrokerAccount
        self.selectedAccountChanged()
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: TradeItSymbolSearchViewControllerDelegate

    func symbolSearchViewController(
        _ symbolSearchViewController: TradeItSymbolSearchViewController,
        didSelectSymbol selectedSymbol: String
    ) {
        self.order.symbol = selectedSymbol
        _ = symbolSearchViewController.navigationController?.popViewController(animated: true)
    }

    // MARK: Private

    private func selectedAccountChanged() {
        self.order.linkedBrokerAccount?.linkedBroker?.authenticateIfNeeded(
            onSuccess: {
//                if self.order.action == .buy {
//                    self.updateAccountOverview()
//                } else {
//                    self.updateSharesOwned()
//                }
            },
            onSecurityQuestion: { securityQuestion, onAnswerSecurityQuestion, onCancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: onAnswerSecurityQuestion,
                    onCancelSecurityQuestion: onCancelSecurityQuestion
                )
            },
            onFailure: { error in
                self.alertManager.showAlertWithAction(
                    error: error,
                    withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                    onViewController: self
                )
            }
        )
    }

    private func updateAccountOverview() {
        self.order.linkedBrokerAccount?.getAccountOverview(
            onSuccess: { accountOverview in
                self.reload(row: .account)
        },
            onFailure: { error in
                self.alertManager.showAlertWithAction(
                    error: error,
                    withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                    onViewController: self
                )
        }
        )
    }

    private func updateSharesOwned() {
        self.order.linkedBrokerAccount?.getPositions(
            onSuccess: { positions in
                self.reload(row: .account)
        },
            onFailure: { error in
                self.alertManager.showAlertWithAction(
                    error: error,
                    withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                    onViewController: self
                )
        }
        )
    }

    private func setTitle() {
        var title = "Trade"

//        if self.order.action != TradeItOrderAction.unknown {
//            title = TradeItOrderActionPresenter.labelFor(self.order.action)
//        }

        if let symbol = self.order.symbol {
            title += " \(symbol)"
        }

        self.title = title
    }

    private func setOrderDefaults() {
//        if self.order.action == .unknown {
//            self.order.action = .buy
//        }
//
//        if self.order.expiration == .unknown {
//            self.order.expiration = .goodForDay
//        }
    }

    private func setPlaceOrderButtonEnablement() {
        if self.order.isValid() {
            self.placeOrderButton.enable()
        } else {
            self.placeOrderButton.disable()
        }
    }

    private func updateMarketData() {
//        if let symbol = self.order.symbol {
//            self.marketDataService.getQuote(
//                symbol: symbol,
//                onSuccess: { quote in
//                    self.quotePresenter = TradeItQuotePresenter(quote, self.order.linkedBrokerAccount?.accountBaseCurrency)
//                    self.order.quoteLastPrice = self.quotePresenter?.getLastPriceValue()
//                    self.reload(row: .marketPrice)
//                    self.reload(row: .estimatedCost)
//            },
//                onFailure: { error in
//                    self.order.quoteLastPrice = nil
//            }
//            )
//        } else {
//            self.order.quoteLastPrice = nil
//        }
    }

    private func reloadTicket() {
        self.setTitle()
        self.setPlaceOrderButtonEnablement()
        self.selectedAccountChanged()
        self.updateMarketData()

        var ticketRows: [TicketRow] = [
            .account,
            .symbol,
            .marketPrice,
            .orderAction,
            .orderType,
            .expiration,
            .amount,
        ]

//        if self.order.requiresLimitPrice() {
//            ticketRows.append(.limitPrice)
//        }
//
//        if self.order.requiresStopPrice() {
//            ticketRows.append(.stopPrice)
//        }

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
        cell.textLabel?.text = ticketRow.getTitle(forAction: .buy) // TODO FIX
        cell.selectionStyle = .none

        TradeItThemeConfigurator.configure(view: cell)

        switch ticketRow {
        case .symbol:
            cell.detailTextLabel?.text = self.order.symbol
        case .orderAction:
            cell.detailTextLabel?.text = "TODO"
        case .amount:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.amount,
                placeholderText: "Amount",
                onValueUpdated: { newValue in
                    self.order.amount = newValue
                    self.reload(row: .estimatedCost)
                    self.setPlaceOrderButtonEnablement()
                }
            )
//        case .limitPrice:
//            (cell as? TradeItNumericInputCell)?.configure(
//                initialValue: self.order.limitPrice,
//                placeholderText: "Enter limit price",
//                onValueUpdated: { newValue in
//                    self.order.limitPrice = newValue
//                    self.reload(row: .estimatedCost)
//                    self.setPreviewButtonEnablement()
//              }
//            )
//        case .stopPrice:
//            (cell as? TradeItNumericInputCell)?.configure(
//                initialValue: self.order.stopPrice,
//                placeholderText: "Enter stop price",
//                onValueUpdated: { newValue in
//                    self.order.stopPrice = newValue
//                    self.reload(row: .estimatedCost)
//                    self.setPreviewButtonEnablement()
//              }
//            )
        case .marketPrice:
            guard let marketCell = cell as? TradeItSubtitleWithDetailsCellTableViewCell else { return cell }
            marketCell.configure(quotePresenter: self.quotePresenter)
        case .estimatedCost:
            var estimateChangeText = "N/A"

            if let estimatedChange = order.estimatedChange() {
                estimateChangeText = NumberFormatter.formatCurrency(
                    estimatedChange,
                    currencyCode: self.order.linkedBrokerAccount?.accountBaseCurrency)
            }

            cell.detailTextLabel?.text = estimateChangeText
//        case .orderType:
//            cell.detailTextLabel?.text = TradeItOrderPriceTypePresenter.labelFor(self.order.type)
//        case .expiration:
//            cell.detailTextLabel?.text = TradeItOrderExpirationPresenter.labelFor(self.order.expiration)
        case .account:
            guard let detailCell = cell as? TradeItSelectionDetailCellTableViewCell else { return cell }
            detailCell.configure(
                detailPrimaryText: self.order.linkedBrokerAccount?.getFormattedAccountName(),
                detailSecondaryText: accountSecondaryText()
            )
        default:
            break
        }
        return cell
    }

    private func accountSecondaryText() -> String? {
        return "Balance: " // TODO
    }
}

protocol TradeItFxTradingTicketViewControllerDelegate: class {
    func orderSuccessfullyPlaced(
        onFxTradingTicketViewController fxTradingTicketViewController: TradeItFxTradingTicketViewController,
        withPlaceOrderResult placeOrderResult: TradeItFxPlaceOrderResult
    )
}
