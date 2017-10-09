import UIKit

class TradeItPortfolioAccountDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withAccount account: TradeItLinkedBrokerAccount) {
        self.accountNameLabel.text = account.getFormattedAccountName()

        if let totalValue = account.balance?.totalValue {
            self.totalValueLabel.text = NumberFormatter.formatCurrency(totalValue, currencyCode: account.accountBaseCurrency)
        } else {
            self.totalValueLabel.text = nil
        }
    }
}
