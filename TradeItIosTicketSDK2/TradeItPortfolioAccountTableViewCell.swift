import UIKit

class TradeItPortfolioAccountTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var returnLabel: UILabel!
    @IBOutlet weak var view: UIView!

    override func awakeFromNib() {
        // TODO: Handle themes
        //TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withAccount account: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceEquityPresenter(account)
        self.accountNameLabel.text = account.getFormattedAccountName()
        self.totalValueLabel.text = presenter.getFormattedTotalValue()
        self.returnLabel.text = presenter.getFormattedDayReturnWithPercentage()
        self.returnLabel.textColor = TradeItPresenter.stockChangeColor(account.balance?.dayAbsoluteReturn?.doubleValue)
        self.setFailedState(account: account)
    }

    private func setFailedState(account: TradeItLinkedBrokerAccount) {
        if account.linkedBroker?.error == nil {
            self.view.alpha = 1.0
        } else {
            self.view.alpha = 0.25
        }
    }
}
