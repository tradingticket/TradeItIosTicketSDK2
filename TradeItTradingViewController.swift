import UIKit
import TradeItIosEmsApi

class TradeItTradingViewController: UIViewController {
    @IBOutlet weak var symbolView: TradeItSymbolView!
    @IBOutlet weak var accountSummaryView: TradeItAccountSummaryView!
    @IBOutlet weak var orderActionButton: UIButton!
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var orderExpirationButton: UIButton!
    @IBOutlet weak var orderSharesInput: UITextField!
    @IBOutlet weak var orderTypeInput1: UITextField!
    @IBOutlet weak var orderTypeInput2: UITextField!
    @IBOutlet weak var estimatedChangeLabel: UILabel!
    @IBOutlet weak var previewOrderButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    static let BOTTOM_CONSTRAINT_CONSTANT = CGFloat(40)

    var order: TradeItOrder!
    var brokerAccount: TradeItLinkedBrokerAccount?
    var symbol: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let order = order else {
            self.navigationController?.popViewControllerAnimated(true)
            print("You must pass an order")
            return
        }

        // Update symbol view
        symbolView.updateSymbol(order.symbol)
        symbolView.updateQuoteActivity(.LOADING)
        TradeItLauncher.quoteManager.getQuote(order.symbol).then({ quote in
            self.order.quoteLastPrice = NSDecimalNumber(string: quote.lastPrice.stringValue)
            self.symbolView.updateQuote(quote)
            self.symbolView.updateQuoteActivity(.LOADED)
        })

        // Update account summary view
        order.brokerAccount.getAccountOverview(onFinished: {
            // QUESTION: Alex was saying something different in the pivotal story - ask him about that
            self.accountSummaryView.updateBrokerAccount(order.brokerAccount)
        })

        order.brokerAccount.getPositions(onFinished: {
            // TODO: Not sure if I should push this down to the accountSummaryView or not
            guard let portfolioPositionIndex = order.brokerAccount.positions.indexOf({ (portfolioPosition: TradeItPortfolioPosition) -> Bool in
                portfolioPosition.position.symbol == order.symbol
            }) else { return }

            let portfolioPosition = order.brokerAccount.positions[portfolioPositionIndex]

            self.accountSummaryView.updateSharesOwned(portfolioPosition.position.quantity)
        })

        registerKeyboardNotifications()

        let orderTypeInputs = [orderSharesInput, orderTypeInput1, orderTypeInput2]
        orderTypeInputs.forEach { input in
            input.addTarget(
                self,
                action: #selector(self.textFieldDidChange(_:)),
                forControlEvents: UIControlEvents.EditingChanged
            )
        }

        orderActionSelected(orderAction: order.action)
        orderTypeSelected(orderType: TradeItOrderTypeHelper.labelFor(order.type))
        orderExpirationSelected(orderExpiration: order.expiration)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Text field change handlers

    func textFieldDidChange(textField: UITextField) {
        if(textField.placeholder == "Limit Price") {
            order.limitPrice = NSDecimalNumber(string: textField.text)
        } else if(textField.placeholder == "Stop Price") {
            order.stopPrice = NSDecimalNumber(string: textField.text)
        } else if(textField.placeholder == "Shares") {
            order.shares = NSDecimalNumber(string: textField.text)
            updateEstimatedChangedLabel()
        }
        updatePreviewOrderButtonStatus()
    }

    // MARK: IBAction for buttons

    @IBAction func orderActionTapped(sender: UIButton) {
        presentOptions(
            "Order Action",
            options: TradeItOrder.ORDER_ACTIONS,
            handler: self.orderActionSelected
        )
    }

    @IBAction func orderTypeTapped(sender: UIButton) {
        presentOptions(
            "Order Type",
            options: TradeItOrderTypeHelper.labels(),
            handler: self.orderTypeSelected
        )
    }

    @IBAction func orderExpirationTapped(sender: UIButton) {
        presentOptions(
            "Order Expiration",
            options: TradeItOrder.ORDER_EXPIRATIONS,
            handler: self.orderExpirationSelected
        )
    }

    @IBAction func previewOrderTapped(sender: UIButton) {
        print("BURP", order.isValid())

    }

    // MARK: Private - Order changed handlers

    private func orderActionSelected(action action: UIAlertAction) {
        orderActionSelected(orderAction: action.title)
    }

    private func orderTypeSelected(action action: UIAlertAction) {
        orderTypeSelected(orderType: action.title)
    }

    private func orderExpirationSelected(action action: UIAlertAction) {
        orderExpirationSelected(orderExpiration: action.title)
    }

    private func orderActionSelected(orderAction orderAction: String!) {
        order.action = orderAction
        orderActionButton.setTitle(order.action, forState: .Normal)

        if(order.action == "Buy") {
            accountSummaryView.updatePresentationMode(.BUYING_POWER)
        } else {
            accountSummaryView.updatePresentationMode(.SHARES_OWNED)
        }

        updateEstimatedChangedLabel()
    }

    private func orderTypeSelected(orderType orderType: String!) {
        order.type = TradeItOrderTypeHelper.enumFor(orderType)
        orderTypeButton.setTitle(TradeItOrderTypeHelper.labelFor(order.type), forState: .Normal)

        // Show/hide order expiration
        if(order.requiresExpiration()) {
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
        if(order.requiresLimitPrice()) {
            configureLimitInput(inputs.removeFirst())
        }
        if(order.requiresStopPrice()) {
            configureStopInput(inputs.removeFirst())
        }

        updatePreviewOrderButtonStatus()
    }

    private func orderExpirationSelected(orderExpiration orderExpiration: String!) {
        order.expiration = orderExpiration
        orderExpirationButton.setTitle(order.expiration, forState: .Normal)
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

    // MARK: Private - Text view configurators

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
            if order.action == "Buy" {
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
            self.bottomConstraint.constant = keyboardFrame.size.height + TradeItTradingViewController.BOTTOM_CONSTRAINT_CONSTANT
        })
    }

    @objc private func keyboardWillHide(_: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = TradeItTradingViewController.BOTTOM_CONSTRAINT_CONSTANT
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
