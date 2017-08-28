import UIKit
import MBProgressHUD

// TODO: Why does changing price type refetch the quote?
class TradeItFxTradingTicketViewController: TradeItViewController, UITableViewDataSource, UITableViewDelegate, TradeItAccountSelectionViewControllerDelegate {
    @IBOutlet weak var tableView: TradeItDismissableKeyboardTableView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var marketDataLabel: UILabel!
    @IBOutlet weak var adContainer: UIView!

    public weak var delegate: TradeItFxTradingTicketViewControllerDelegate?

    internal var order = TradeItFxOrder()

    private var alertManager = TradeItAlertManager()
    private let viewProvider = TradeItViewControllerProvider()
    private var selectionViewController: TradeItSelectionViewController!
    private var accountSelectionViewController: TradeItAccountSelectionViewController!
    private var keyboardOffsetContraintManager: TradeItKeyboardOffsetConstraintManager?
    private var quote: TradeItQuote?
    private var orderCapabilities: TradeItFxOrderCapabilities?

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

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()

        TicketRow.registerNibCells(forTableView: self.tableView)

        self.updateOrderCapabilities()

        TradeItSDK.adService.populate?(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .trading,
            position: .bottom,
            broker: self.order.linkedBrokerAccount?.linkedBroker?.brokerName,
            symbol: self.order.symbol,
            instrumentType: TradeItTradeInstrumentType.fx.rawValue,
            trackPageViewAsPageType: true
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTicket()
        self.marketDataLabel.text = nil
        if self.order.symbol == nil {
            self.pushSymbolSelection()
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticketRow = self.ticketRows[indexPath.row]

        switch ticketRow {
        case .symbol:
            self.pushSymbolSelection()
        case .account:
            self.navigationController?.pushViewController(self.accountSelectionViewController, animated: true)
        case .orderAction:
            self.pushOrderCapabilitiesSelection(field: .actions, value: self.order.actionType) { selection in
                self.order.actionType = selection
            }
        case .priceType:
            self.pushOrderCapabilitiesSelection(field: .priceTypes, value: self.order.priceType) { selection in
                self.order.priceType = selection
                self.order.expirationType = self.orderCapabilities?.defaultValueFor(field: .expirationTypes, value: nil)
                if self.order.requiresRate() {
                    self.updateMarketData()
                }
            }
        case .expiration:
            self.pushOrderCapabilitiesSelection(field: .expirationTypes, value: self.order.expirationType) { selection in
                self.order.expirationType = selection
            }
        case .leverage:
            self.selectionViewController.initialSelection = self.order.leverage?.stringValue
            self.selectionViewController.selections = self.orderCapabilities?.leverageOptions?.map { $0.stringValue } ?? []
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
                            forError: errorResult,
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
                    forError: errorResult,
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
        self.updateMarketData()
        _ = self.navigationController?.popViewController(animated: true)
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
                        activityView.hide(animated: true)

                        self.orderCapabilities = orderCapabilities

                        self.setOrderDefaults()
                        self.setSymbol(orderCapabilities.tradeItSymbol)
                        self.updateMarketData()

                        self.reloadTicket()
                    },
                    onFailure: { error in
                        activityView.hide(animated: true)
                        self.alertManager.showAlertWithAction(
                            forError: error,
                            withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                            onViewController: self,
                            onFinished: {
                                self.handleValidationError(error)
                            }
                        )
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
                    forError: error,
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
                    forError: error,
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
                    forError: error,
                    withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                    onViewController: self
                )
            }
        )
    }

    private func setTitle() {
        var title = "Trade"

        if let actionType = self.orderCapabilities?.labelFor(field: .actions, value: self.order.actionType) {
            title = actionType
        }

        if let symbol = self.order.symbol {
            title += " \(symbol)"
        }

        self.title = title
    }

    private func setOrderDefaults() {
        self.order.actionType = self.orderCapabilities?.defaultValueFor(field: .actions, value: self.order.actionType)
        self.order.priceType = self.orderCapabilities?.defaultValueFor(field: .priceTypes, value: self.order.priceType)
        self.order.expirationType = self.orderCapabilities?.defaultValueFor(field: .expirationTypes, value: self.order.expirationType)
        self.order.leverage = self.orderCapabilities?.leverageOptions?.first
    }

    private func setPlaceOrderButtonEnablement() {
        if self.order.isValid() {
            self.placeOrderButton.enable()
        } else {
            self.placeOrderButton.disable()
        }
    }

    private func updateMarketData() {
        self.order.rate = nil
        self.reload(row: .rate)
        if let symbol = self.order.symbol, let linkedBroker = self.order.linkedBrokerAccount?.linkedBroker {
            linkedBroker.getFxQuote(
                symbol: symbol,
                onSuccess: { quote in
                    self.marketDataLabel.text = "Market data provided by \(linkedBroker.brokerName)."
                    self.quote = quote
                    self.order.rate = TradeItQuotePresenter.numberToDecimalNumber(quote.bidPrice)
                    self.reload(row: .bid)
                    self.reload(row: .rate)
                },
                onFailure: { error in
                    self.order.rate = nil
                    self.reload(row: .rate)
                }
            )
        }
    }

    private func reloadTicket() {
        self.setTitle()
        self.setPlaceOrderButtonEnablement()

        var ticketRows: [TicketRow] = [
            .account,
            .symbol,
            .bid,
            .orderAction,
            .priceType
        ]

        if self.order.requiresRate() {
            ticketRows.append(.rate)
        }
        
        ticketRows.append(.amount)
        
        if let leverageOptions = self.orderCapabilities?.leverageOptions, leverageOptions.count > 0 {
            ticketRows.append(.leverage)
        }

        if self.order.requiresExpiration() {
            ticketRows.append(.expiration)
        }

        self.ticketRows = ticketRows

        self.tableView.reloadData()
    }

    private func reload(row: TicketRow) {
        guard let indexOfRow = self.ticketRows.index(of: row) else { return }

        let indexPath = IndexPath.init(row: indexOfRow, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func provideCell(rowIndex: Int) -> UITableViewCell {
        let ticketRow = self.ticketRows[rowIndex]

        let cell = tableView.dequeueReusableCell(withIdentifier: ticketRow.cellReuseId) ?? UITableViewCell()
        cell.textLabel?.text = ticketRow.getTitle(forAction: .buy) // TODO FIX
        cell.selectionStyle = .none

        TradeItThemeConfigurator.configure(view: cell)

        let quotePresenter = TradeItQuotePresenter(
            "",
            minimumFractionDigits: self.orderCapabilities?.precision?.intValue ?? 4,
            maximumFractionDigits: self.orderCapabilities?.precision?.intValue ?? 4
        )

        switch ticketRow {
        case .symbol:
            cell.detailTextLabel?.text = self.order.symbol
        case .orderAction:
            cell.detailTextLabel?.text = self.orderCapabilities?.labelFor(field: .actions, value: self.order.actionType)
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
            let initialValue = quotePresenter.formatCurrency(self.order.rate)
            (cell as? TradeItStepperInputTableViewCell)?.configure(
                initialValue: initialValue,
                placeholderText: "Enter rate",
                maxDecimalPlaces: self.orderCapabilities?.precision?.intValue,
                onValueUpdated: { newValue in
                    self.order.rate = newValue
                    self.setPlaceOrderButtonEnablement()
              }
            )
        case .bid:
            guard let marketCell = cell as? TradeItSubtitleWithDetailsCellTableViewCell else { return cell }
            marketCell.configure(
                subtitleLabel: quotePresenter.formatTimestamp(quote?.dateTime),
                detailsLabel: quote?.bidPrice?.stringValue,
                subtitleDetailsLabel: quotePresenter.formatChange(change: quote?.change, percentChange: quote?.pctChange),
                subtitleDetailsLabelColor: TradeItQuotePresenter.getChangeLabelColor(changeValue: quote?.change)
            )
        case .priceType:
            cell.detailTextLabel?.text = self.orderCapabilities?.labelFor(field: .priceTypes, value: self.order.priceType)
        case .expiration:
            cell.detailTextLabel?.text = self.orderCapabilities?.labelFor(field: .expirationTypes, value: self.order.expirationType)
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

    private func pushOrderCapabilitiesSelection(
        field: TradeItInstrumentOrderCapabilityField,
        value: String?,
        onSelected: @escaping (String?) -> Void
    ) {
        guard let orderCapabilities = self.orderCapabilities else { return }
        self.selectionViewController.initialSelection = orderCapabilities.labelFor(field: field, value: value)
        self.selectionViewController.selections = orderCapabilities.labelsFor(field: field)
        self.selectionViewController.onSelected = { selection in
            onSelected(orderCapabilities.valueFor(field: field, label: selection))
            _ = self.navigationController?.popViewController(animated: true)
        }

        self.navigationController?.pushViewController(selectionViewController, animated: true)
    }


    private func setSymbol(_ symbol: String?) {
        self.order.symbol = symbol
        self.setTitle()
        self.reload(row: .symbol)
    }

    private func pushSymbolSelection() {
        guard let broker = self.order.linkedBrokerAccount?.brokerName else { return }

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Fetching available currencies"

        TradeItSDK.symbolService.fxSymbols(
            forBroker: broker,
            onSuccess: { symbols in
                activityView.hide(animated: true)
                self.selectionViewController.initialSelection = self.order.symbol
                self.selectionViewController.selections = symbols
                self.selectionViewController.onSelected = { selection in
                    self.setSymbol(selection)
                    _ = self.navigationController?.popViewController(animated: true)
                    self.updateOrderCapabilities()
                    self.updateMarketData()
                }

                self.navigationController?.pushViewController(self.selectionViewController, animated: true)
            },
            onFailure: { error in
                activityView.hide(animated: true)
                self.alertManager.showAlertWithAction(
                    forError: error,
                    withLinkedBroker: self.order.linkedBrokerAccount?.linkedBroker,
                    onViewController: self,
                    onFinished: {
                        self.handleValidationError(error)
                    }
                )
            }
        )
    }

    private func handleValidationError(_ error: TradeItErrorResult) {
        guard let errorFields = error.errorFields as? [String] else { return }
        if (errorFields.contains("symbol")) {
            self.order.symbol = nil
            self.pushSymbolSelection()
        }
        if (errorFields.contains("account")) {
            self.navigationController?.pushViewController(self.accountSelectionViewController, animated: true)
        }
    }
}

protocol TradeItFxTradingTicketViewControllerDelegate: class {
    func orderSuccessfullyPlaced(
        onFxTradingTicketViewController fxTradingTicketViewController: TradeItFxTradingTicketViewController,
        withPlaceOrderResult placeOrderResult: TradeItFxPlaceOrderResult
    )
}
