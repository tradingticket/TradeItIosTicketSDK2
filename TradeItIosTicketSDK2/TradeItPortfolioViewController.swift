import UIKit

class TradeItPortfolioViewController: UIViewController {

    var accounts: [TradeItAccount] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("accounts available on portfolio screen: \(self.accounts)")
    }
    
}
