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

        self.confirmationTextLabel.text = "NOTHING TO SEE HERE, FOLKS..."

        if let orderDetails = self.previewOrderResult?.orderDetails {
            let actionText = orderDetails.orderAction
            // TODO: SHOULD BE USING placeOrderResult.orderInfo.quantity INSTEAD OF orderDetails.orderQuantity
            let quantityText = NumberFormatter.formatQuantity(orderDetails.orderQuantity)
            let symbolText = orderDetails.orderSymbol
            let priceText = orderDetails.orderPrice

            let confirmationMessage = "Your order to \(actionText) \(quantityText) shares of \(symbolText) at \(priceText) has been successfully transmitted to your broker"

            self.confirmationTextLabel.text = confirmationMessage
        }

        self.timeStampLabel.text = self.placeOrderResult?.timestamp ?? "N/A"
        self.orderNumberLabel.text = "Order #\(self.placeOrderResult?.orderNumber ?? "")"
   }
    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(self)
    }
    
    @IBAction func portfolioButtonWasTapped(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
            navigationController.setViewControllers([portfolioViewController], animated: true)
        }
    }
}

protocol TradeItTradingConfirmationViewControllerDelegate: class {
    func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItTradingConfirmationViewController)
}
