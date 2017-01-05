import UIKit

class TradeItAccountSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabelValue: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureTableCell(cell: self)
    }

    func populate(withLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalancePresenterFactory.forTradeItLinkedBrokerAccount(linkedBrokerAccount)
        self.accountNameLabel.text = linkedBrokerAccount.getFormattedAccountName()
        self.buyingPowerLabelValue.text = presenter.getFormattedBuyingPower()
    }
}
