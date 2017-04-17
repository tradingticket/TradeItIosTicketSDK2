import UIKit

@objc class TradeItTradingConfirmationViewController: TradeItViewController {
    @IBOutlet weak var confirmationTextLabel: UILabel!
    @IBOutlet weak var viewPortfolioButton: UIButton!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var tradeAgainButton: UIButton!

    var previewOrderResult: TradeItPreviewOrderResult?
    var placeOrderResult: TradeItPlaceOrderResult?
    var viewControllerProvider = TradeItViewControllerProvider()
    var tradingUIFlow = TradeItTradingUIFlow()

    weak var delegate: TradeItTradingConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.timeStampLabel.textColor = UIColor.tradeItlightGreyTextColor
        self.orderNumberLabel.textColor = UIColor.tradeItlightGreyTextColor
        self.tradeAgainButton.backgroundColor = UIColor.tradeItCoolBlueColor
        self.viewPortfolioButton.backgroundColor = UIColor.tradeItDarkBlueColor

        self.viewPortfolioButton.isHidden = !TradeItSDK.isPortfolioEnabled

        self.setConfirmationMessage()

        self.timeStampLabel.text = self.placeOrderResult?.timestamp ?? ""
        self.orderNumberLabel.text = "Order #\(self.placeOrderResult?.orderNumber ?? "")"
   }

    // MARK: IBActions
    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(self)
    }
    
    @IBAction func portfolioButtonWasTapped(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioAccountsView)
            navigationController.setViewControllers([portfolioViewController], animated: true)
        }
    }

    // MARK: Private
    private func setConfirmationMessage() {
        let orderDetails = self.previewOrderResult?.orderDetails
        let orderInfo = self.placeOrderResult?.orderInfo

        let actionText = orderInfo?.action ?? "[MISSING ACTION]"
        let symbolText = orderInfo?.symbol ?? "[MISSING SYMBOL]"
        let priceText = orderDetails?.orderPrice ?? "[MISSING PRICE]"
        var quantityText = "[MISSING QUANTITY]"

        if let quantity = orderInfo?.quantity {
            quantityText = NumberFormatter.formatQuantity(quantity)
        }

        let confirmationMessage = "Your order to \(actionText) \(quantityText) shares of \(symbolText) at \(priceText) has been successfully transmitted to your broker"

        self.confirmationTextLabel.text = confirmationMessage
    }
}

protocol TradeItTradingConfirmationViewControllerDelegate: class {
    func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItTradingConfirmationViewController)
}
