import UIKit

class TradeItAccountSelectionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalancePresenterFactory.forTradeItLinkedBrokerAccount(linkedBrokerAccount)
        self.textLabel?.text = linkedBrokerAccount.getFormattedAccountName()

        self.detailTextLabel?.text = ""
        let buyingPower = presenter.getFormattedBuyingPower()

        if buyingPower != TradeItPresenter.MISSING_DATA_PLACEHOLDER {
            self.detailTextLabel?.text = "Buying power: " + buyingPower
        }
    }
}
