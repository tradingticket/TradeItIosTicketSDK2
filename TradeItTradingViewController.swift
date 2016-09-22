import UIKit
import TradeItIosEmsApi

class TradeItTradingViewController: UIViewController {
    @IBOutlet weak var symbolButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var stockPriceLabel: UILabel!
    @IBOutlet weak var stockPriceChangeLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        symbolButton.setTitle("GE", forState: .Normal)
    }
}
