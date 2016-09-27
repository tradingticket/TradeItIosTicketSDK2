import UIKit
import TradeItIosEmsApi

class TradeItOrder {
    var orderAction: String?
    var orderType: String?
    var orderExpiration: String?
    var shares: NSDecimalNumber?
    var limitPrice: NSDecimalNumber?
    var stopPrice: NSDecimalNumber?
    var quoteLastPrice: NSDecimalNumber?

    init() {}

    func requiresLimitPrice() -> Bool {
        guard let orderType = orderType else { return false }
        return ["Limit", "Stop Limit"].contains(orderType)
    }

    func requiresStopPrice() -> Bool {
        guard let orderType = orderType else { return false }
        return ["Stop Market", "Stop Limit"].contains(orderType)
    }

    func requiresExpiration() -> Bool {
        guard let orderType = orderType else { return false }
        return orderType != "Market"
    }

    func estimatedChange() -> NSDecimalNumber? {
        guard let quoteLastPrice = quoteLastPrice,
            let shares = shares
            where shares != NSDecimalNumber.notANumber()
            else { return nil }

        return quoteLastPrice.decimalNumberByMultiplyingBy(shares)
    }
}

class TradeItTradingViewController: UIViewController {
    @IBOutlet weak var quoteView: TradeItQuoteView!
    @IBOutlet weak var orderActionButton: UIButton!
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var orderExpirationButton: UIButton!
    @IBOutlet weak var orderSharesInput: UITextField!
    @IBOutlet weak var orderTypeInput1: UITextField!
    @IBOutlet weak var orderTypeInput2: UITextField!
    @IBOutlet weak var estimatedChangeLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    static let DEFAULT_ORDER_ACTION = "Buy"
    static let ORDER_ACTIONS = ["Buy", "Sell", "Buy to Cover", "Sell Short"]
    static let DEFAULT_ORDER_TYPE = "Market"
    static let ORDER_TYPES = ["Market", "Limit", "Stop Market", "Stop Limit"]
    static let DEFAULT_ORDER_EXPIRATION = "Good for the Day"
    static let ORDER_EXPIRATIONS = ["Good for the Day", "Good until Canceled"]
    static let BOTTOM_CONSTRAINT_CONSTANT = CGFloat(40)

    var order: TradeItOrder!
    var brokerAccount: TradeItLinkedBrokerAccount?
    var symbol: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let brokerAccount = brokerAccount,
            let symbol = symbol else {
                self.navigationController?.popViewControllerAnimated(true)
                print("You must pass a valid broker account and symbol")
                return
        }

        // QUESTION: Best way to pass in the symbol?
        quoteView.updateSymbol(symbol)

        TradeItLauncher.quoteManager.getQuote(symbol).then({ quote in
            self.order.quoteLastPrice = NSDecimalNumber(string: quote.lastPrice.stringValue)
            self.quoteView.updateQuote(quote)
        })

        brokerAccount.getAccountOverview(onFinished: {
            self.quoteView.updateBrokerAccount(brokerAccount)
        })

        order = TradeItOrder()

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

        let orderTypeInputs = [orderSharesInput, orderTypeInput1, orderTypeInput2]
        orderTypeInputs.forEach { input in
            input.addTarget(
                self,
                action: #selector(self.textFieldDidChange(_:)),
                forControlEvents: UIControlEvents.EditingChanged
            )
        }

        orderActionSelected(orderAction: TradeItTradingViewController.DEFAULT_ORDER_ACTION)
        orderTypeSelected(orderType: TradeItTradingViewController.DEFAULT_ORDER_TYPE)
        orderExpirationSelected(orderExpiration: TradeItTradingViewController.DEFAULT_ORDER_EXPIRATION)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Keyboard event handlers

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + TradeItTradingViewController.BOTTOM_CONSTRAINT_CONSTANT
        })
    }

    func keyboardWillHide(_: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = TradeItTradingViewController.BOTTOM_CONSTRAINT_CONSTANT
        })
    }

    // MARK: Text field change handlers

    func textFieldDidChange(textField: UITextField) {
        if(textField.placeholder == "Limit Price") {
            order.limitPrice = NSDecimalNumber(string: textField.text)
        } else if(textField.placeholder == "Stop Price") {
            order.stopPrice = NSDecimalNumber(string: textField.text)
        } else if(textField.placeholder == "Shares") {
            order.shares = NSDecimalNumber(string: textField.text)
            let estimatedChange = order.estimatedChange()
            if let estimatedChange = estimatedChange {
                estimatedChangeLabel.text = NumberFormatter.formatCurrency(estimatedChange)
            } else {
                estimatedChangeLabel.text = nil
            }
        }
    }

    // MARK: IBAction for buttons

    @IBAction func orderActionTapped(sender: UIButton) {
        presentOptions(
            "Order Action",
            options: TradeItTradingViewController.ORDER_ACTIONS,
            handler: self.orderActionSelected
        )
    }

    @IBAction func orderTypeTapped(sender: UIButton) {
        presentOptions(
            "Order Type",
            options: TradeItTradingViewController.ORDER_TYPES,
            handler: self.orderTypeSelected
        )
    }

    @IBAction func orderExpirationTapped(sender: UIButton) {
        presentOptions(
            "Order Expiration",
            options: TradeItTradingViewController.ORDER_EXPIRATIONS,
            handler: self.orderExpirationSelected
        )
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

    private func orderActionSelected(orderAction orderAction: String?) {
        order.orderAction = orderAction
        orderActionButton.setTitle(order.orderAction, forState: .Normal)

        if(order.orderAction == "Buy") {
            quoteView.updatePresentationMode(.BUYING_POWER)
        } else {
            quoteView.updatePresentationMode(.SHARES_OWNED)
        }
    }

    private func orderTypeSelected(orderType orderType: String?) {
        order.orderType = orderType
        orderTypeButton.setTitle(order.orderType, forState: .Normal)

        // Show/hide order expiration
        if(order.requiresExpiration()) {
            orderExpirationButton.superview?.hidden = false
        } else {
            orderExpirationButton.superview?.hidden = true
            order.orderExpiration = nil
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
    }

    private func orderExpirationSelected(orderExpiration orderExpiration: String?) {
        order.orderExpiration = orderExpiration
        orderExpirationButton.setTitle(order.orderExpiration, forState: .Normal)
    }

    // MARK: Text view configurators

    private func configureLimitInput(input: UITextField) {
        input.placeholder = "Limit Price"
        input.hidden = false
    }

    private func configureStopInput(input: UITextField) {
        input.placeholder = "Stop Price"
        input.hidden = false
    }

    // MARK: Action sheet helper

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
