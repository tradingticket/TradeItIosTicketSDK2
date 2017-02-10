import UIKit

@objc class TradeItTradingConfirmationViewController: TradeItViewController {
    @IBOutlet weak var confirmationTextLabel: UILabel!
    @IBOutlet weak var viewPortfolioButton: UIButton!
    var placeOrderResult: TradeItPlaceOrderResult?
    var viewControllerProvider = TradeItViewControllerProvider()
    var tradingUIFlow = TradeItTradingUIFlow()

    weak var delegate: TradeItTradingConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let placeOrderResult = placeOrderResult else { return }

        confirmationTextLabel.text = placeOrderResult.confirmationMessage
        viewPortfolioButton.isHidden = !TradeItSDK.isPortfolioEnabled
   }
    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(self)
    }
    
    @IBAction func portfolioButtonWasTapped(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
            navigationController.setViewControllers([initialViewController], animated: true)
        }
    }
}

protocol TradeItTradingConfirmationViewControllerDelegate: class {
    func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItTradingConfirmationViewController)
}
