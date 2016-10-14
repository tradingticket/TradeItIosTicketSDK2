import UIKit

class TradeItTradingConfirmationViewController: UIViewController {
    @IBOutlet weak var confirmationTextLabel: UILabel!
    var placeOrderResult: TradeItPlaceTradeResult?
    var viewControllerProvider = TradeItViewControllerProvider()
    var tradingUIFlow = TradeItTradingUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    weak var delegate: TradeItTradingConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()

        guard let placeOrderResult = placeOrderResult else { return }
        confirmationTextLabel.text = placeOrderResult.confirmationMessage
   }
    @IBAction func tradeButtonWasTapped(sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(self)
    }
    
    @IBAction func portfolioButtonWasTapped(sender: AnyObject) {
        if let navigationController = self.navigationController {
            let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
            navigationController.setViewControllers([initialViewController], animated: true)
        }
    }
}

protocol TradeItTradingConfirmationViewControllerDelegate: class {
    func tradeButtonWasTapped(tradeItTradingConfirmationViewController: TradeItTradingConfirmationViewController)
}
