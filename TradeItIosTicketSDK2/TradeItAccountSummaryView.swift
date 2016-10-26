import UIKit

class TradeItAccountSummaryView: UIView {

    @IBOutlet weak var accountEquitySummaryView: TradeItEquityAccountSummaryView!
    @IBOutlet weak var accountFxSummaryView: TradeItFxAccountSummaryView!
    @IBOutlet weak var summaryLabel: UILabel!

    func populate(withAccount selectedAccount: TradeItLinkedBrokerAccount) {
        if selectedAccount.balance != nil {
            self.accountFxSummaryView.isHidden = true
            self.accountEquitySummaryView.isHidden = false
            self.accountEquitySummaryView.populate(withAccount: selectedAccount)
        }
        else if selectedAccount.fxBalance != nil {
            self.accountEquitySummaryView.isHidden = true
            self.accountFxSummaryView.isHidden = false
            self.accountFxSummaryView.populate(withAccount: selectedAccount)
        }
    }
}
