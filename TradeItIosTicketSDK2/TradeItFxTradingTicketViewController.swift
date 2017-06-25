import UIKit
import MBProgressHUD

// TODO: Why does changing price type refetch the quote?
class TradeItFxTradingTicketViewController: TradeItViewController, UITableViewDataSource, UITableViewDelegate, TradeItAccountSelectionViewControllerDelegate {
    @IBOutlet weak var tableView: TradeItDismissableKeyboardTableView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!

    public weak var delegate: TradeItFxTradingTicketViewControllerDelegate?

    internal var order = TradeItFxOrder()

    private var alertManager = TradeItAlertManager()
    private let viewProvider = TradeItViewControllerProvider()
    private var selectionViewController: TradeItSelectionViewController!
    private var accountSelectionViewController: TradeItAccountSelectionViewController!
    private let marketDataService = TradeItSDK.marketDataService
    private var keyboardOffsetContraintManager: TradeItKeyboardOffsetConstraintManager?
    private var quote: TradeItQuote?

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

        self.keyboardOffsetContraintManager = TradeItKeyboardOffsetConstraintManager(
            bottomConstraint: self.tableViewBottomConstraint,
            viewController: self
        )

        self.setOrderDefaults()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()

        TicketRow.registerNibCells(forTableView: self.tableView)

        self.updateOrderCapabilities()
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
            guard let broker = self.order.linkedBrokerAccount?.brokerName else { return }
            TradeItSDK.symbolService.fxSymbols( // TODO ADD SPINNER otherwise if user taps twice it will crash
                forBroker: broker,
                onSuccess: { symbols in
                    self.selectionViewController.initialSelection = self.order.symbol
                    self.selectionViewController.selections = symbols
                    self.selectionViewController.onSelected = { selection in
                        self.order.symbol = selection
                        _ = self.navigationController?.popViewController(animated: true)
                    }

                    self.navigationController?.pushViewController(self.selectionViewController, animated: true)
                },
                onFailure: { error in
                    self.alertManager.showAlertWithAction(
                        error: error,
                        withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                        onViewController: self
                    )
                }
            )
        case .account:
            self.navigationController?.pushViewController(self.accountSelectionViewController, animated: true)
        case .orderAction:
            //  self.selectionViewController.initialSelection = self.order.linkedBrokerAccount?.orderCapabilities.first {
            // TEST
            self.selectionViewController.initialSelection = TradeItFxOrderActionPresenter.labelFor(self.order.action)
            self.selectionViewController.selections = TradeItFxOrderActionPresenter.labels()
            self.selectionViewController.onSelected = { (selection: String) in
                self.order.action = TradeItFxOrderActionPresenter.enumFor(selection)
                _ = self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
        case .orderType:
            self.selectionViewController.initialSelection = TradeItFxOrderPriceTypePresenter.labelFor(self.order.type)
            self.selectionViewController.selections = TradeItFxOrderPriceTypePresenter.labels()
            self.selectionViewController.onSelected = { (selection: String) in
                self.order.type = TradeItFxOrderPriceTypePresenter.enumFor(selection)
                _ = self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
        case .expiration:
            self.selectionViewController.initialSelection = TradeItFxOrderExpirationPresenter.labelFor(self.order.expiration)
            self.selectionViewController.selections = TradeItFxOrderExpirationPresenter.labels()
            self.selectionViewController.onSelected = { (selection: String) in
                self.order.expiration = TradeItFxOrderExpirationPresenter.enumFor(selection)
                _ = self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
        case .leverage:
            self.selectionViewController.initialSelection = self.order.leverage?.stringValue
            self.selectionViewController.selections = ["1", "5", "10"]
            self.selectionViewController.onSelected = { selection in
                if let selectionInt = Int(selection) {
                    let selectionNumber = NSNumber(value: selectionInt)
                    self.order.leverage = selectionNumber
                }
                _ = self.navigationController?.popViewController(animated: true)
            }

            self.navigationController?.pushViewController(selectionViewController, animated: true)
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
        self.updateOrderCapabilities()
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

    private func updateOrderCapabilities() {
        guard let symbol = self.order.symbol, let linkedBrokerAccount = self.order.linkedBrokerAccount else { return }

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        self.order.linkedBrokerAccount?.linkedBroker?.authenticateIfNeeded(
            onSuccess: {
                activityView.label.text = "Fetching order capabilities"
                self.order.linkedBrokerAccount?.fxTradeService.getOrderCapabilities(
                    linkedBrokerAccount: linkedBrokerAccount,
                    symbol: symbol,
                    onSuccess: { orderCapabilities in
                        print(orderCapabilities)
                        activityView.hide(animated: true)

                        self.reloadTicket()
                    },
                    onFailure: { error in
                        print(error)
                        activityView.hide(animated: true)
                    }
                )
                self.updateAccountOverview()
                // TODO: Show current position if sell action?
            },
            onSecurityQuestion: { securityQuestion, onAnswerSecurityQuestion, onCancelSecurityQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: onAnswerSecurityQuestion,
                    onCancelSecurityQuestion: onCancelSecurityQuestion
                )
            },
            onFailure: { error in
                activityView.hide(animated: true)
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

        if self.order.action != TradeItFxOrderAction.unknown {
            title = TradeItFxOrderActionPresenter.labelFor(self.order.action)
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

    private func setPlaceOrderButtonEnablement() {
        if self.order.isValid() {
            self.placeOrderButton.enable()
        } else {
            self.placeOrderButton.disable()
        }
    }

    private func updateMarketData() {
        if let symbol = self.order.symbol, let broker = self.order.linkedBrokerAccount?.brokerName {
            self.marketDataService.getFxQuote?(
                symbol: symbol,
                broker: broker,
                onSuccess: { quote in
                    self.quote = quote
                    self.order.bidPrice = TradeItQuotePresenter.numberToDecimalNumber(quote.bidPrice)
                    self.reload(row: .bid)
                },
                onFailure: { error in
                    self.order.bidPrice = nil
                }
            )
        } else {
            self.order.bidPrice = nil
        }
    }

    private func reloadTicket() {
        self.setTitle()
        self.setPlaceOrderButtonEnablement()
        //self.selectedAccountChanged()
        self.updateMarketData()

        var ticketRows: [TicketRow] = [
            .account,
            .symbol,
            .bid,
            .orderAction,
            .orderType,
            .amount
        ]

        if self.order.requiresLimitPrice() {
            ticketRows.append(.rate)
        }

        if true { // TODO: self.order.linkedBrokerAccount?.orderCapabilities(forInstrument: .FX)
            ticketRows.append(.leverage)
        }

        if self.order.requiresExpiration() {
            ticketRows.append(.expiration)
        }

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
            cell.detailTextLabel?.text = TradeItFxOrderActionPresenter.labelFor(self.order.action)
        case .amount:
            (cell as? TradeItNumericInputCell)?.configure(
                initialValue: self.order.amount,
                placeholderText: "Amount",
                onValueUpdated: { newValue in
                    self.order.amount = newValue
                    self.setPlaceOrderButtonEnablement()
                }
            )
        case .rate:
            (cell as? TradeItStepperInputTableViewCell)?.configure(
                initialValue: self.order.limitPrice,
                placeholderText: "Enter limit price",
                onValueUpdated: { newValue in
                    self.order.limitPrice = newValue
                    self.setPlaceOrderButtonEnablement()
              }
            )
        case .bid:
            guard let marketCell = cell as? TradeItSubtitleWithDetailsCellTableViewCell else { return cell }
            let quotePresenter = TradeItQuotePresenter(
                "",
                minimumFractionDigits: 4,
                maximumFractionDigits: 4
            )
            marketCell.configure(
                subtitleLabel: quotePresenter.formatTimestamp(quote?.dateTime),
                detailsLabel: quotePresenter.formatCurrency(quote?.bidPrice),
                subtitleDetailsLabel: quotePresenter.formatChange(change: quote?.change, percentChange: quote?.pctChange),
                subtitleDetailsLabelColor: TradeItQuotePresenter.getChangeLabelColor(changeValue: quote?.change)
            )
        case .orderType:
            cell.detailTextLabel?.text = TradeItFxOrderPriceTypePresenter.labelFor(self.order.type)
        case .expiration:
            cell.detailTextLabel?.text = TradeItFxOrderExpirationPresenter.labelFor(self.order.expiration)
        case .account:
            guard let detailCell = cell as? TradeItSelectionDetailCellTableViewCell else { return cell }
            detailCell.configure(
                detailPrimaryText: self.order.linkedBrokerAccount?.getFormattedAccountName(),
                detailSecondaryText: accountSecondaryText()
            )
        case .leverage:
            cell.detailTextLabel?.text = self.order.leverage?.stringValue
        default:
            break
        }
        return cell
    }

    private func accountSecondaryText() -> String? {
        guard let buyingPower = self.order.linkedBrokerAccount?.fxBalance?.buyingPowerBaseCurrency else { return nil }
        return "Buying Power: " + NumberFormatter.formatCurrency(
            buyingPower,
            currencyCode: self.order.linkedBrokerAccount?.accountBaseCurrency
        )
    }
}

protocol TradeItFxTradingTicketViewControllerDelegate: class {
    func orderSuccessfullyPlaced(
        onFxTradingTicketViewController fxTradingTicketViewController: TradeItFxTradingTicketViewController,
        withPlaceOrderResult placeOrderResult: TradeItFxPlaceOrderResult
    )
}
