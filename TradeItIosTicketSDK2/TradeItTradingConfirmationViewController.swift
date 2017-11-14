import UIKit

@objc class TradeItTradingConfirmationViewController: TradeItViewController {
    @IBOutlet weak var confirmationTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var viewOrderStatusButton: UIButton!
    @IBOutlet weak var tradeAgainButton: UIButton!
    @IBOutlet weak var adContainer: UIView!

    var timestamp: String?
    var confirmationMessage: String?
    var orderNumber: String?
    var order: TradeItOrder?
    var viewControllerProvider = TradeItViewControllerProvider()
    var tradingUIFlow = TradeItTradingUIFlow()

    // Analytics tracking only
    var broker: String?
    var symbol: String?
    var instrument: String?

    weak var delegate: TradeItTradingConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewOrderStatusButton.isHidden = !TradeItSDK.isPortfolioEnabled

        self.timeStampLabel.text = self.timestamp
        self.orderNumberLabel.text = "Order #\(self.orderNumber ?? "")"
        self.confirmationTextLabel.text = confirmationMessage

        TradeItSDK.adService.populate(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .confirmation,
            position: .bottom,
            broker: broker,
            symbol: symbol,
            instrumentType: instrument,
            trackPageViewAsPageType: true
        )
   }

    // MARK: IBActions
    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(self)
    }
    
    @IBAction func orderStatusButtonWasTapped(_ sender: Any) {
        guard let order = self.order
            , let linkedBrokerAccount = order.linkedBrokerAccount else {
            return
        }
        if let navigationController = self.navigationController {
            guard let ordersViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.ordersView) as? TradeItOrdersViewController else { return }
            ordersViewController.linkedBrokerAccount = linkedBrokerAccount
            navigationController.setViewControllers([ordersViewController], animated: true)
        }
    }

}

protocol TradeItTradingConfirmationViewControllerDelegate: class {
    func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItTradingConfirmationViewController)
}
