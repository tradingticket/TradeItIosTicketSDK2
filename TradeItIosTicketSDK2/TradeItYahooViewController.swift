import UIKit

class TradeItYahooViewController: TradeItViewController {
    override func viewDidLoad() {
        self.enableThemeOnLoad = false
        super.viewDidLoad()
        self.enableCustomNavController()
    }
}
