import UIKit

class TradeItAccountSummaryView: UIView {
    @IBOutlet weak var accountEquitySummaryView: TradeItEquityAccountSummaryView!
    @IBOutlet weak var summaryLabel: UILabel!

    func populate(withAccount selectedAccount: TradeItLinkedBrokerAccount) {
        self.accountEquitySummaryView.isHidden = false
        self.accountEquitySummaryView.populate(withAccount: selectedAccount)
    }
}
