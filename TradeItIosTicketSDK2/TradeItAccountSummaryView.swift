import UIKit

class TradeItAccountSummaryView: UIView {

    @IBOutlet weak var accountEquitySummaryView: TradeItEquityAccountSummaryView!
    @IBOutlet weak var accountFxSummaryView: TradeItFxAccountSummaryView!
    @IBOutlet weak var summaryLabel: UILabel!

    func populate(withAccount selectedAccount: TradeItLinkedBrokerAccount) {
        if selectedAccount.balance != nil {
            self.accountFxSummaryView.hidden = true
            self.accountEquitySummaryView.hidden = false
            self.accountEquitySummaryView.populate(withAccount: selectedAccount)
        }
        else if selectedAccount.fxBalance != nil {
            self.accountEquitySummaryView.hidden = true
            self.accountFxSummaryView.hidden = false
            self.accountFxSummaryView.populate(withAccount: selectedAccount)
        }
    }
}
