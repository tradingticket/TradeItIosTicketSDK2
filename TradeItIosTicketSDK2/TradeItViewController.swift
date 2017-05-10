import UIKit

class TradeItViewController: CloseableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        TradeItThemeConfigurator.configure(view: self.view)
    }
}
