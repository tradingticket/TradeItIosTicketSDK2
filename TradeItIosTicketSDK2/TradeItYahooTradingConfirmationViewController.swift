import UIKit

@objc class TradeItYahooTradingConfirmationViewController: UIViewController {
    @IBOutlet weak var brokerLabel: UILabel!

    var placeOrderResult: TradeItPlaceOrderResult?
    var viewControllerProvider = TradeItViewControllerProvider()
    var tradingUIFlow = TradeItTradingUIFlow()

    weak var delegate: TradeItYahooTradingConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let placeOrderResult = placeOrderResult else { return }

//        confirmationTextLabel.text = placeOrderResult.confirmationMessage
//        viewPortfolioButton.isHidden = !TradeItSDK.isPortfolioEnabled
    }

//    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
//        self.delegate?.tradeButtonWasTapped(self)
//    }

//    @IBAction func portfolioButtonWasTapped(_ sender: AnyObject) {
//        if let navigationController = self.navigationController {
//            let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
//            navigationController.setViewControllers([initialViewController], animated: true)
//        }
//    }
}

// TODO: Add to YahooTradingUIFlow
protocol TradeItYahooTradingConfirmationViewControllerDelegate: class {
    //func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItYahooTradingConfirmationViewController)
}
