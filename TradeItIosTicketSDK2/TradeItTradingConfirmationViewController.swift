import UIKit

@objc class TradeItTradingConfirmationViewController: TradeItViewController {
    @IBOutlet weak var confirmationTextLabel: UILabel!
    @IBOutlet weak var viewPortfolioButton: UIButton!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var tradeAgainButton: UIButton!
    @IBOutlet weak var adContainer: UIView!

    var timestamp: String?
    var confirmationMessage: String?
    var orderNumber: String?
    var viewControllerProvider = TradeItViewControllerProvider()
    var tradingUIFlow = TradeItTradingUIFlow()

    weak var delegate: TradeItTradingConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPortfolioButton.isHidden = !TradeItSDK.isPortfolioEnabled

        self.timeStampLabel.text = self.timestamp
        self.orderNumberLabel.text = "Order #\(self.orderNumber ?? "")"
        self.confirmationTextLabel.text = confirmationMessage

        TradeItSDK.adService.populate(adContainer: adContainer, rootViewController: self, pageType: .confirmation, position: .bottom)
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
}

protocol TradeItTradingConfirmationViewControllerDelegate: class {
    func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItTradingConfirmationViewController)
}
