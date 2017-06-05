import UIKit

class TradeItAccountSelectionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceEquityPresenter(linkedBrokerAccount)
        self.textLabel?.text = linkedBrokerAccount.getFormattedAccountName()

        self.detailTextLabel?.text = ""

        if let buyingPower = presenter.getFormattedBuyingPowerLabelWithTimestamp() {
            self.detailTextLabel?.text = buyingPower
        }
    }
}
