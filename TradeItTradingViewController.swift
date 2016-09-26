import UIKit
import TradeItIosEmsApi

class TradeItOrderTypePresenter {
    internal let orderType: String
    internal let requiresExpiration: Bool
    internal let requiresLimit: Bool
    internal let requiresStop: Bool

    init(orderType: String, requiresExpiration: Bool, requiresLimit: Bool = false, requiresStop: Bool = false) {
        self.orderType = orderType
        self.requiresExpiration = requiresExpiration
        self.requiresLimit = requiresLimit
        self.requiresStop = requiresStop
    }
}

class TradeItTradingViewController: UIViewController {
    @IBOutlet weak var quoteView: TradeItQuoteView!
    @IBOutlet weak var orderActionButton: UIButton!
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var orderExpirationButton: UIButton!
    @IBOutlet weak var orderTypeInput1: UITextField!
    @IBOutlet weak var orderTypeInput2: UITextField!

    static let DEFAULT_ORDER_ACTION = "Buy"
    static let ORDER_ACTIONS = [
        "Buy",
        "Sell",
        "Buy to Cover",
        "Sell Short"
    ]
    static let DEFAULT_ORDER_TYPE = "Market"
    static let ORDER_TYPES_MAP = [
        "Market": TradeItOrderTypePresenter(orderType: "market", requiresExpiration: false),
        "Limit": TradeItOrderTypePresenter(orderType: "limit", requiresExpiration: true, requiresLimit: true),
        "Stop Market": TradeItOrderTypePresenter(
            orderType: "stopMarket",
            requiresExpiration: true,
            requiresLimit: false,
            requiresStop: true
        ),
        "Stop Limit": TradeItOrderTypePresenter(
            orderType: "stopLimit",
            requiresExpiration: true,
            requiresLimit: true,
            requiresStop: true
        )
    ]
    static let DEFAULT_ORDER_EXPIRATION = "Good for the Day"
    static let ORDER_EXPIRATIONS = [
        "Good for the Day",
        "Good until Canceled"
    ]

    var brokerAccount: TradeItLinkedBrokerAccount?
    var symbol: String?
    var orderAction: String = DEFAULT_ORDER_ACTION

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

        TradeItLauncher.quoteManager.getQuote(symbol).then(quoteView.updateQuote)

        brokerAccount.getAccountOverview(onFinished: {
            self.quoteView.updateBrokerAccount(brokerAccount)
        })

        orderActionSelected(orderAction: TradeItTradingViewController.DEFAULT_ORDER_ACTION)
        orderTypeSelected(orderType: TradeItTradingViewController.DEFAULT_ORDER_TYPE)
        orderExpirationSelected(orderExpiration: TradeItTradingViewController.DEFAULT_ORDER_EXPIRATION)
    }


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
            options: Array(TradeItTradingViewController.ORDER_TYPES_MAP.keys),
            handler: self.orderTypeSelected
        )
    }

    @IBAction func orderExpirationTapped(sender: UIButton) {
        presentOptions(
            "Order Expiration",
            options: Array(TradeItTradingViewController.ORDER_EXPIRATIONS),
            handler: self.orderExpirationSelected
        )
    }

    func orderActionSelected(action action: UIAlertAction) {
        if(action.style == .Cancel) { return }
        orderActionSelected(orderAction: action.title)
    }

    func orderActionSelected(orderAction orderAction: String?) {
        guard let orderAction = orderAction else { return }
        orderActionButton.setTitle(orderAction, forState: .Normal)

        // TODO: Update quote with number of shares owned if they select SELL
    }

    func orderTypeSelected(action action: UIAlertAction) {
        if(action.style == .Cancel) { return }
        orderTypeSelected(orderType: action.title)
    }

    func orderTypeSelected(orderType orderType: String?) {
        guard let orderType = orderType,
            let orderTypePresenter = TradeItTradingViewController.ORDER_TYPES_MAP[orderType] else { return }

        orderTypeButton.setTitle(orderType, forState: .Normal)

        if(orderTypePresenter.requiresExpiration) {
            orderExpirationButton.superview?.hidden = false
        } else {
            orderExpirationButton.superview?.hidden = true
        }

        var inputs = [orderTypeInput1, orderTypeInput2]
        inputs.forEach { input in
            input.hidden = true
            input.text = nil
        }
        if(orderTypePresenter.requiresLimit) {
            configureLimitInput(inputs.removeFirst())
        }
        if(orderTypePresenter.requiresStop) {
            configureStopInput(inputs.removeFirst())
        }
    }

    private func orderExpirationSelected(action action: UIAlertAction) {
        if(action.style == .Cancel) { return }
        orderExpirationSelected(orderExpiration: action.title)
    }

    private func orderExpirationSelected(orderExpiration orderExpiration: String?) {
        guard let orderExpiration = orderExpiration else { return }
        orderExpirationButton.setTitle(orderExpiration, forState: .Normal)
    }

    private func configureLimitInput(input: UITextField) {
        input.placeholder = "Limit Price"
        input.hidden = false
    }

    private func configureStopInput(input: UITextField) {
        input.placeholder = "Stop Price"
        input.hidden = false
    }

    private func presentOptions(title: String, options: [String], handler: (UIAlertAction) -> Void) {
        let actionSheet: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .ActionSheet
        )

        options.forEach { option in
            actionSheet.addAction(UIAlertAction(
                title: option,
                style: .Default,
                handler: handler
                ))
        }

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}
