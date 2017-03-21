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
        self.setStyleForAccountState(account: account)
    }

    private func setStyleForAccountState(account: TradeItLinkedBrokerAccount) {
        if account.linkedBroker?.error == nil {
            self.accessoryType = .disclosureIndicator
            self.view.alpha = 1.0
        } else {
            self.accessoryType = .none
            self.view.alpha = 0.25
        }
    }
}
