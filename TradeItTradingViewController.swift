import UIKit
import TradeItIosEmsApi

class TradeItTradingViewController: UIViewController {
    @IBOutlet weak var quoteView: TradeItQuoteView!

    var brokerAccount: TradeItLinkedBrokerAccount?

    override func viewDidLoad() {
        super.viewDidLoad()

        quoteView.updateSymbol("TSLA")

        TradeItLauncher.quoteManager.getQuote("TSLA").then(quoteView.updateQuote)

        guard let brokerAccount = brokerAccount else {
            self.navigationController?.popViewControllerAnimated(true)
            print("You must pass a valid broker account")
            return
        }

        brokerAccount.getAccountOverview(onFinished: {
            self.quoteView.updateBrokerAccount(brokerAccount)
        })
    }

}
