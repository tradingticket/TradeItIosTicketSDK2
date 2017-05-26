import UIKit

class TradeItPortfolioAccountDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var dayReturnLabel: UILabel!
    @IBOutlet weak var totalReturnLabel: UILabel!
    @IBOutlet weak var availableCashLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!

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

        let presenter = TradeItPortfolioBalanceEquityPresenter(account)
        self.dayReturnLabel.text = presenter.getFormattedDayReturnWithPercentage()
        self.dayReturnLabel.textColor = TradeItPresenter.stockChangeColor(account.balance?.dayAbsoluteReturn?.doubleValue)
        self.totalReturnLabel.text = presenter.getFormattedTotalReturnValueWithPercentage() ?? ""
        self.totalReturnLabel.textColor = TradeItPresenter.stockChangeColor(account.balance?.totalAbsoluteReturn?.doubleValue)
        self.availableCashLabel.text = presenter.getFormattedAvailableCash()
        self.buyingPowerLabel.text = presenter.getFormattedBuyingPower()
    }
}
