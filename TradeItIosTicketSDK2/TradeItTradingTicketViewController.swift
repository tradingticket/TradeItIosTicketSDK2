import UIKit

class TradeItTradingTicketViewController: UIViewController, TradeItSymbolSearchViewControllerDelegate, TradeItAccountSelectionViewControllerDelegate {
    @IBOutlet weak var symbolView: TradeItSymbolView!
    @IBOutlet weak var tradingBrokerAccountView: TradeItTradingBrokerAccountView!
    @IBOutlet weak var orderActionButton: UIButton!
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var orderExpirationButton: UIButton!
    @IBOutlet weak var orderSharesInput: UITextField!
    @IBOutlet weak var orderTypeInput1: UITextField!
    @IBOutlet weak var orderTypeInput2: UITextField!
    @IBOutlet weak var estimatedChangeLabel: UILabel!
    @IBOutlet weak var previewOrderButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    static let BOTTOM_CONSTRAINT_CONSTANT = CGFloat(20)

    var alertManager = TradeItAlertManager()
    var viewControllerProvider = TradeItViewControllerProvider()
    var ezLoadingActivityManager = EZLoadingActivityManager()
    var marketDataService = TradeItLauncher.marketDataService
    var order = TradeItOrder()

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.order.linkedBrokerAccount == nil {
            assertionFailure("TradeItIosTicketSDK ERROR: TradeItTradingTicketViewController loaded without setting linkedBrokerAccount on order.")
        }
        orderActionSelected(orderAction: TradeItOrderActionPresenter.labelFor(order.action))
        orderTypeSelected(orderType: TradeItOrderPriceTypePresenter.labelFor(order.type))
        orderExpirationSelected(orderExpiration: TradeItOrderExpirationPresenter.labelFor(order.expiration))
        
        updateSymbolView()
        updateTradingBrokerAccountView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
        registerTextFieldNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Text field change handlers

    func textFieldDidChange(textField: UITextField) {
        // TODO: Should probably check the order price type instead of placeholder text to determine which value changed
        if textField.placeholder == "Limit Price" {
            order.limitPrice = NSDecimalNumber(string: textField.text)
        } else if textField.placeholder == "Stop Price" {
            order.stopPrice = NSDecimalNumber(string: textField.text)
        } else if textField.placeholder == "Shares" {
            order.quantity = NSDecimalNumber(string: textField.text)
            updateEstimatedChangedLabel()
        }
        updatePreviewOrderButtonStatus()
    }

    // MARK: IBActions

    @IBAction func orderActionTapped(sender: UIButton) {
        presentOptions(
            "Order Action",
            options: TradeItOrderActionPresenter.labels(),
            handler: self.orderActionSelected
        )
    }

    @IBAction func orderTypeTapped(sender: UIButton) {
        presentOptions(
            "Order Type",
            options: TradeItOrderPriceTypePresenter.labels(),
            handler: self.orderTypeSelected
        )
    }

    @IBAction func orderExpirationTapped(sender: UIButton) {
        presentOptions(
            "Order Expiration",
            options: TradeItOrderExpirationPresenter.labels(),
            handler: self.orderExpirationSelected
        )
    }

    @IBAction func previewOrderTapped(sender: UIButton) {
        self.ezLoadingActivityManager.show(text: "Previewing Order", disableUI: true)

        order.preview(onSuccess: { previewOrder, placeOrderCallback in
            let storyboard = UIStoryboard(name: "TradeIt", bundle: TradeItBundleProvider.provide())
            let tradingPreviewViewController = storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.tradingPreviewView.rawValue) as! TradeItTradingPreviewViewController

            tradingPreviewViewController.linkedBrokerAccount = self.order.linkedBrokerAccount
            tradingPreviewViewController.previewOrder = previewOrder
            tradingPreviewViewController.placeOrderCallback = placeOrderCallback

            self.navigationController?.pushViewController(tradingPreviewViewController, animated: true)
            self.ezLoadingActivityManager.hide()
        }, onFailure: { errorResult in
            self.ezLoadingActivityManager.hide()
            self.alertManager.show(tradeItErrorResult: errorResult, onViewController: self, withLinkedBroker: self.order.linkedBrokerAccount!.linkedBroker, onFinished: {})
        })
    }

    @IBAction func symbolButtonWasTapped(sender: AnyObject) {
        presentSymbolSelectionScreen()
    }

    @IBAction func accountButtonTapped(sender: UIButton) {
        presentAccountSelectionScreen()
    }

    // MARK: Private

    private func presentSymbolSelectionScreen() {
        let symbolSearchViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.symbolSearchView) as! TradeItSymbolSearchViewController

        symbolSearchViewController.delegate = self

        self.navigationController?.pushViewController(symbolSearchViewController, animated: true)
    }

    private func presentAccountSelectionScreen() {
        let accountSelectionViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.accountSelectionView) as! TradeItAccountSelectionViewController

        accountSelectionViewController.delegate = self

        self.navigationController?.pushViewController(accountSelectionViewController, animated: true)
    }

    // MARK: TradeItSymbolSearchViewControllerDelegate

    func symbolSearchViewController(symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String) {
        self.order.symbol = selectedSymbol
        updateSymbolView()
        updateTradingBrokerAccountView()
        symbolSearchViewController.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: TradeItAccountSelectionViewControllerDelegate

    func accountSelectionViewController(accountSelectionViewController: TradeItAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.order.linkedBrokerAccount = linkedBrokerAccount
        updateTradingBrokerAccountView()
        accountSelectionViewController.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: Private - Order changed handlers

    private func orderActionSelected(action: UIAlertAction) {
        orderActionSelected(orderAction: action.title)
    }

    private func orderTypeSelected(action action: UIAlertAction) {
        orderTypeSelected(orderType: action.title)
    }

    private func orderExpirationSelected(action: UIAlertAction) {
        orderExpirationSelected(orderExpiration: action.title)
    }

    private func orderActionSelected(orderAction orderAction: String!) {
        order.action = TradeItOrderActionPresenter.enumFor(orderAction)
        orderActionButton.setTitle(TradeItOrderActionPresenter.labelFor(order.action), forState: .Normal)

        if order.action == .Buy {
            tradingBrokerAccountView.updatePresentationMode(.BUYING_POWER)
        } else {
            tradingBrokerAccountView.updatePresentationMode(.SHARES_OWNED)
        }
    }

    private func orderTypeSelected(orderType orderType: String!) {
        order.type = TradeItOrderPriceTypePresenter.enumFor(orderType)
        orderTypeButton.setTitle(TradeItOrderPriceTypePresenter.labelFor(order.type), forState: .Normal)

        // Show/hide order expiration
        if order.requiresExpiration() {
            orderExpirationButton.superview?.hidden = false
        } else {
            orderExpirationButton.superview?.hidden = true
        }

        // Show/hide limit and/or stop
        var inputs = [orderTypeInput1, orderTypeInput2]

        inputs.forEach { input in
            input.hidden = true
            input.text = nil
        }

        if order.requiresLimitPrice() {
            configureLimitInput(inputs.removeFirst())
        }

        if order.requiresStopPrice() {
            configureStopInput(inputs.removeFirst())
        }

        updatePreviewOrderButtonStatus()
    }

    private func orderExpirationSelected(orderExpiration orderExpiration: String!) {
        order.expiration = TradeItOrderExpirationPresenter.enumFor(orderExpiration)
        orderExpirationButton.setTitle(TradeItOrderExpirationPresenter.labelFor(order.expiration), forState: .Normal)
    }

    private func updatePreviewOrderButtonStatus() {
        if order.isValid() {
            previewOrderButton.enabled = true
            previewOrderButton.backgroundColor = UIColor.tradeItClearBlueColor()
        } else {
            previewOrderButton.enabled = false
            previewOrderButton.backgroundColor = UIColor.tradeItGreyishBrownColor()
        }
    }

    private func updateSymbolView() {
        guard let symbol = order.symbol else { return }

        symbolView.updateSymbol(symbol)
        symbolView.updateQuoteActivity(.LOADING)

        self.marketDataService.getQuote(symbol, onSuccess: { quote in
            let presenter = TradeItQuotePresenter(quote)
            self.order.quoteLastPrice = presenter.getLastPriceValue()
            self.symbolView.updateQuote(quote)
            self.symbolView.updateQuoteActivity(.LOADED)
            self.updateEstimatedChangedLabel()
        }, onFailure: { error in
            print("Error: \(error)")
            self.symbolView.updateQuoteActivity(.LOADED)
        })

        updateSharesOwnedLabel()
    }

    private func updateTradingBrokerAccountView() {
        guard let linkedBrokerAccount = order.linkedBrokerAccount else { return }

        linkedBrokerAccount.getAccountOverview(onSuccess: {
            self.tradingBrokerAccountView.updateBrokerAccount(linkedBrokerAccount)
        }, onFailure: { errorResult in
            print(errorResult)
        })

        updateSharesOwnedLabel()
    }

    private func updateSharesOwnedLabel() {
        guard let symbol = order.symbol
            , let linkedBrokerAccount = order.linkedBrokerAccount
            else { return }

        linkedBrokerAccount.getPositions(onSuccess: {
            let positionsMatchingSymbol = linkedBrokerAccount.positions.filter { portfolioPosition in
                TradeItPortfolioPositionPresenterFactory.forTradeItPortfolioPosition(portfolioPosition).getFormattedSymbol() == symbol
            }

            guard let position = positionsMatchingSymbol.first else { return }

            let presenter = TradeItPortfolioPositionPresenterFactory.forTradeItPortfolioPosition(position)
            self.tradingBrokerAccountView.updateSharesOwned(presenter)
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

    // MARK: Private - Text view configurators

    private func registerTextFieldNotifications() {
        let orderTypeInputs = [orderSharesInput, orderTypeInput1, orderTypeInput2]

        orderTypeInputs.forEach { input in
            input.addTarget(
                self,
                action: #selector(self.textFieldDidChange(_:)),
                forControlEvents: UIControlEvents.EditingChanged
            )
        }
    }

    private func configureLimitInput(input: UITextField) {
        input.placeholder = "Limit Price"
        input.hidden = false
    }

    private func configureStopInput(input: UITextField) {
        input.placeholder = "Stop Price"
        input.hidden = false
    }

    private func updateEstimatedChangedLabel() {
        if let estimatedChange = order.estimatedChange() {
            let formattedEstimatedChange = NumberFormatter.formatCurrency(estimatedChange)
            if order.action == .Buy {
                estimatedChangeLabel.text = "Est. Cost \(formattedEstimatedChange)"
            } else {
                estimatedChangeLabel.text = "Est. Proceeds \(formattedEstimatedChange)"
            }
        } else {
            estimatedChangeLabel.text = nil
        }
    }

    // MARK: Private - Keyboard event handlers

    private func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + TradeItTradingTicketViewController.BOTTOM_CONSTRAINT_CONSTANT
        })
    }

    @objc private func keyboardWillHide(_: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = TradeItTradingTicketViewController.BOTTOM_CONSTRAINT_CONSTANT
        })
    }

    // MARK: Private - Action sheet helper

    private func presentOptions(title: String, options: [String], handler: (UIAlertAction) -> Void) {
        let actionSheet: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .ActionSheet
        )

        options.map { option in UIAlertAction(title: option, style: .Default, handler: handler) }
            .forEach(actionSheet.addAction)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}
