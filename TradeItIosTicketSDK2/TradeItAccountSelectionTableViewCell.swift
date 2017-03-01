import UIKit

class TradeItAccountSelectionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalancePresenterFactory.forTradeItLinkedBrokerAccount(linkedBrokerAccount)
        self.textLabel?.text = linkedBrokerAccount.getFormattedAccountName()
        self.detailTextLabel?.text = presenter.getFormattedBuyingPower()
    }
}
