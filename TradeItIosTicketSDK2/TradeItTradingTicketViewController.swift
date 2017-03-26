import UIKit
import MBProgressHUD

class TradeItTradingTicketViewController: TradeItViewController, TradeItSymbolSearchViewControllerDelegate, TradeItAccountSelectionViewControllerDelegate {
    @IBOutlet weak var symbolView: TradeItSymbolView!
    @IBOutlet weak var tradingBrokerAccountView: TradeItTradingBrokerAccountView!
    @IBOutlet weak var orderActionButton: UIButton!
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var orderExpirationButton: UIButton!
    @IBOutlet weak var orderQuantityInput: UITextField!
    @IBOutlet weak var orderTypeInput1: UITextField!
    @IBOutlet weak var orderTypeInput2: UITextField!
    @IBOutlet weak var estimatedChangeLabel: UILabel!
    @IBOutlet weak var previewOrderButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var buttonBackgrounds: [UIView]!

    static let BOTTOM_CONSTRAINT_CONSTANT = CGFloat(20)

    var alertManager = TradeItAlertManager()
    weak var delegate: TradeItTradingTicketViewControllerDelegate?
    
    var viewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItOrder()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let linkedBrokerAccount = self.order.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItTradingTicketViewController loaded without setting linkedBrokerAccount on order.")
        }

        self.buttonBackgrounds.forEach { buttonBackground in
            // TODO: Why isn't this done in the theme configurator in TradeItViewController?
            buttonBackground.backgroundColor = TradeItSDK.theme.inputFrameColor
        }

        // TODO: Ew, this shouldn't be done here
        self.tradingBrokerAccountView.resourceAvailabilityDescriptionLabel.textColor = UIColor.tradeItlightGreyTextColor
        self.symbolView.updatedAtLabel.textColor = UIColor.tradeItlightGreyTextColor

        self.prepopulateOrderForm()
        self.set(linkedBrokerAccount: linkedBrokerAccount)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerTextFieldNotifications()
    
        guard let linkedBroker = self.order.linkedBrokerAccount?.linkedBroker, linkedBroker.isStillLinked() else {
            self.presentAccountSelectionScreen()
            return
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Text field change handlers

    func textFieldDidChange(_ textField: UITextField) {
        // TODO: Should probably check the order price type instead of placeholder text to determine which value changed
        if textField.placeholder == "Limit Price" {
            order.limitPrice = NSDecimalNumber(string: textField.text)
        } else if textField.placeholder == "Stop Price" {
            order.stopPrice = NSDecimalNumber(string: textField.text)
        } else if textField.placeholder == "Quantity" {
            order.quantity = NSDecimalNumber(string: textField.text)
        }
        updateEstimatedChangedLabel()
        updatePreviewOrderButtonStatus()
    }

    // MARK: IBActions

    @IBAction func orderActionTapped(_ sender: UIButton) {
        presentOptions(
            title: "Order Action",
            options: TradeItOrderActionPresenter.labels(),
            sender: sender,
            handler: { action in
                self.orderActionSelected(action)
                self.updateHeaderViews()
            }
        )
    }

    @IBAction func orderTypeTapped(_ sender: UIButton) {
        presentOptions(
            title: "Order Type",
            options: TradeItOrderPriceTypePresenter.labels(),
            sender: sender,
            handler: self.orderTypeSelected
        )
    }

    @IBAction func orderExpirationTapped(_ sender: UIButton) {
        presentOptions(
            title: "Order Expiration",
            options: TradeItOrderExpirationPresenter.labels(),
            sender: sender,
            handler: self.orderExpirationSelected
        )
    }

    @IBAction func previewOrderTapped(_ sender: UIButton) {
        guard let linkedBroker = self.order.linkedBrokerAccount?.linkedBroker
            else { return }

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                activityView.label.text = "Previewing Order"
                self.order.preview(
                    onSuccess: { previewOrderResult, placeOrderCallback in
                        activityView.hide(animated: true)
                        self.delegate?.orderSuccessfullyPreviewed(onTradingTicketViewController: self,
                                                                  withPreviewOrderResult: previewOrderResult,
                                                                  placeOrderCallback: placeOrderCallback)
                    }, onFailure: { error in
                        activityView.hide(animated: true)
                        self.alertManager.showRelinkError(
                            error,
                            withLinkedBroker: linkedBroker,
                            onViewController: self,
                            onFinished: {} // TODO: Retry?
                        )
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
                self.alertManager.showRelinkError(errorResult,
                    withLinkedBroker: linkedBroker,
                    onViewController: self,
                    onFinished: {})
            }
        )
    }

    @IBAction func symbolButtonWasTapped(_ sender: AnyObject) {
        presentSymbolSelectionScreen()
    }

    @IBAction func accountButtonTapped(_ sender: UIButton) {
        presentAccountSelectionScreen()
    }

    // MARK: Private

    private func prepopulateOrderForm() {
        self.orderActionSelected(orderAction: TradeItOrderActionPresenter.labelFor(order.action))
        self.orderTypeSelected(orderType: TradeItOrderPriceTypePresenter.labelFor(order.type))
        self.orderExpirationSelected(orderExpiration: TradeItOrderExpirationPresenter.labelFor(order.expiration))

        orderQuantityInput.text = order.quantity?.stringValue
        switch order.type {
        case .limit:
            orderTypeInput1.text = order.limitPrice?.stringValue
        case .stopMarket:
            orderTypeInput1.text = order.stopPrice?.stringValue
        case .stopLimit:
            orderTypeInput1.text = order.limitPrice?.stringValue
            orderTypeInput2.text = order.stopPrice?.stringValue
        default:
            break
        }
    }

    private func updateHeaderViews() {
        guard let linkedBrokerAccount = order.linkedBrokerAccount,
            let linkedBroker = linkedBrokerAccount.linkedBroker
            else { return }

        self.tradingBrokerAccountView.updateBrokerAccount(linkedBrokerAccount)
        self.updateSymbolView()

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Updating Account Info"

        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                switch self.tradingBrokerAccountView.presentationMode {
                case .buyingPower:
                    linkedBrokerAccount.getAccountOverview(
                        onSuccess: { accountOverview in
                            activityView.hide(animated: true)

                            // TODO: FIX THIS PRESENTER TO TAKE ACCOUNT OVERVIEW
                            let presenter = TradeItPortfolioBalanceEquityPresenter(linkedBrokerAccount)
                            self.tradingBrokerAccountView.updateBuyingPower(presenter.getFormattedBuyingPower())
                        },
                        onFailure: { errorResult in
                            activityView.hide(animated: true)
                            self.alertManager.showError(errorResult, onViewController: self)
                        }
                    )
                case .sharesOwned:
                    // TODO: MAKE DEFAULT LinkedBrokerAccount.positions = nil
                    if !linkedBrokerAccount.positions.isEmpty  {
                        activityView.hide(animated: true)
                        self.updateBrokerAccountViewPosition(forSymbol: self.order.symbol, fromPositions: linkedBrokerAccount.positions)
                    } else {
                        linkedBrokerAccount.getPositions(
                            onSuccess: { positions in
                                activityView.hide(animated: true)
                                self.updateBrokerAccountViewPosition(forSymbol: self.order.symbol, fromPositions: positions)
                            },
                            onFailure: { errorResult in
                                activityView.hide(animated: true)
                                self.alertManager.showError(errorResult, onViewController: self)
                            }
                        )
                    }
                }
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelQuestion
                )
            },
            onFailure: { errorResult in
                activityView.hide(animated: true)
                self.alertManager.showRelinkError(
                    errorResult,
                    withLinkedBroker: linkedBroker,
                    onViewController: self,
                    onFinished: {
                        // TODO: If we call self.updateHeaderViews() again will this get stuck in a loop?
                    }
                )
            }
        )
    }

    private func updateBrokerAccountViewPosition(forSymbol symbol: String?, fromPositions positions: [TradeItPortfolioPosition]) {

        let positionsMatchingSymbol = positions.filter { position in
            TradeItPortfolioEquityPositionPresenter(position).getFormattedSymbol() == symbol
        }

        self.tradingBrokerAccountView.updatePosition(positionsMatchingSymbol.first)
    }

    private func presentSymbolSelectionScreen() {
        let symbolSearchViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.symbolSearchView) as! TradeItSymbolSearchViewController

        symbolSearchViewController.delegate = self

        self.navigationController?.pushViewController(symbolSearchViewController, animated: true)
    }

    private func presentAccountSelectionScreen() {
        let accountSelectionViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.accountSelectionView) as! TradeItAccountSelectionViewController

        accountSelectionViewController.delegate = self

        if let linkedBrokerAccount = self.order.linkedBrokerAccount {
            accountSelectionViewController.selectedLinkedBrokerAccount = linkedBrokerAccount
        }

        self.navigationController?.pushViewController(accountSelectionViewController, animated: true)
    }

    // MARK: TradeItSymbolSearchViewControllerDelegate

    func symbolSearchViewController(_ symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String) {
        _ = symbolSearchViewController.navigationController?.popViewController(animated: true)

        self.set(symbol: selectedSymbol)
    }

    // MARK: TradeItAccountSelectionViewControllerDelegate

    func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.set(linkedBrokerAccount: linkedBrokerAccount)
        _ = accountSelectionViewController.navigationController?.popViewController(animated: true)
    }

    // MARK: Private - Order changed handlers

    private func set(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        guard self.order.linkedBrokerAccount?.linkedBroker != nil else {
            return self.alertManager.showError(TradeItErrorResult(
                title: "Broker unlinked",
                message: "The broker was unlinked. Please select another account.",
                code: .systemError
            ), onViewController: self)
        }

        self.order.linkedBrokerAccount = linkedBrokerAccount

        self.updateHeaderViews()
    }

    private func set(symbol: String) {
        self.order.symbol = symbol

        self.updateHeaderViews()
    }

    private func orderActionSelected(_ action: UIAlertAction) {
        orderActionSelected(orderAction: action.title)
    }

    private func orderTypeSelected(action: UIAlertAction) {
        orderTypeSelected(orderType: action.title)
    }

    private func orderExpirationSelected(_ action: UIAlertAction) {
        orderExpirationSelected(orderExpiration: action.title)
    }

    private func orderActionSelected(orderAction: String!) {
        order.action = TradeItOrderActionPresenter.enumFor(orderAction)
        orderActionButton.setTitle(TradeItOrderActionPresenter.labelFor(order.action), for: UIControlState())

        if [.buy, .buyToCover].contains(order.action) {
            tradingBrokerAccountView.updatePresentationMode(.buyingPower)
        } else {
            tradingBrokerAccountView.updatePresentationMode(.sharesOwned)
        }
    }

    private func orderTypeSelected(orderType: String!) {
        order.type = TradeItOrderPriceTypePresenter.enumFor(orderType)
        orderTypeButton.setTitle(TradeItOrderPriceTypePresenter.labelFor(order.type), for: UIControlState())

        // Show/hide order expiration
        if order.requiresExpiration() {
            orderExpirationButton.superview?.isHidden = false
        } else {
            orderExpirationButton.superview?.isHidden = true
        }

        // Show/hide limit and/or stop
        var inputs = [orderTypeInput1, orderTypeInput2]

        inputs.forEach { input in
            input?.isHidden = true
            input?.text = nil
        }

        if order.requiresLimitPrice() {
            configureLimitInput(inputs.removeFirst()!)
        }

        if order.requiresStopPrice() {
            configureStopInput(inputs.removeFirst()!)
        }

        updatePreviewOrderButtonStatus()
    }

    private func orderExpirationSelected(orderExpiration: String!) {
        self.order.expiration = TradeItOrderExpirationPresenter.enumFor(orderExpiration)
        self.orderExpirationButton.setTitle(TradeItOrderExpirationPresenter.labelFor(order.expiration), for: UIControlState())
    }

    private func updatePreviewOrderButtonStatus() {
        if order.isValid() {
            self.previewOrderButton.enable()
        } else {
            self.previewOrderButton.disable()
        }
    }

    private func updateSymbolView() {
        guard let symbol = order.symbol else { return }

        self.symbolView.updateSymbol(symbol)
        self.symbolView.updateQuoteActivity(.loading)

        TradeItSDK.marketDataService.getQuote(symbol: symbol, onSuccess: { quote in
            let presenter = TradeItQuotePresenter(quote)
            self.order.quoteLastPrice = presenter.getLastPriceValue()
            self.symbolView.updateQuote(quote)
            self.symbolView.updateQuoteActivity(.loaded)
            self.updateEstimatedChangedLabel()
        }, onFailure: { error in
            self.order.quoteLastPrice = nil
            self.symbolView.updateQuote(nil)
            self.symbolView.updateQuoteActivity(.loaded)
            self.updateEstimatedChangedLabel()
        })
    }

    // MARK: Private - Text view configurators

    private func registerTextFieldNotifications() {
        let toolbar = UIToolbar()

        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.black
        toolbar.sizeToFit()

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )

        toolbar.setItems([spacer, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true

        orderTypeInputs().forEach { input in
            input.addTarget(
                self,
                action: #selector(self.textFieldDidChange(_:)),
                for: UIControlEvents.editingChanged
            )
            input.inputAccessoryView = toolbar
        }
    }

    private func orderTypeInputs() -> [UITextField] {
        return [orderQuantityInput, orderTypeInput1, orderTypeInput2]
    }

    func dismissKeyboard() {
        orderTypeInputs().forEach { input in
            input.resignFirstResponder()
        }
    }

    private func configureLimitInput(_ input: UITextField) {
        input.placeholder = "Limit Price"
        input.isHidden = false
    }

    private func configureStopInput(_ input: UITextField) {
        input.placeholder = "Stop Price"
        input.isHidden = false
    }

    private func updateEstimatedChangedLabel() {
        if let estimatedChange = order.estimatedChange() {
            let formattedEstimatedChange = NumberFormatter.formatCurrency(estimatedChange, currencyCode: TradeItPresenter.DEFAULT_CURRENCY_CODE)
            if order.action == .buy {
                estimatedChangeLabel.text = "Est. Cost \(formattedEstimatedChange)"
            } else {
                estimatedChangeLabel.text = "Est. Proceeds \(formattedEstimatedChange)"
            }
        } else {
            estimatedChangeLabel.text = nil
        }
    }

    // MARK: Private - Action sheet helper

    private func presentOptions(title: String, options: [String], sender: UIButton, handler: @escaping (UIAlertAction) -> Void) {
        let actionSheet: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )

        actionSheet.popoverPresentationController?.sourceView = sender

        options.map { option in UIAlertAction(title: option, style: .default, handler: handler) }
            .forEach(actionSheet.addAction)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
}

protocol TradeItTradingTicketViewControllerDelegate: class {
    func orderSuccessfullyPreviewed(
        onTradingTicketViewController tradingTicketViewController: TradeItTradingTicketViewController,
        withPreviewOrderResult previewOrderResult: TradeItPreviewOrderResult,
        placeOrderCallback: @escaping TradeItPlaceOrderHandlers
    )
}
