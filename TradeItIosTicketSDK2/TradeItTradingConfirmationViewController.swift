import UIKit

class TradeItTradingConfirmationViewController: UIViewController {
    @IBOutlet weak var confirmationTextLabel: UILabel!

    var placeOrderResult: TradeItPlaceTradeResult?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let placeOrderResult = placeOrderResult else { return }
        confirmationTextLabel.text = placeOrderResult.confirmationMessage
   }
}
