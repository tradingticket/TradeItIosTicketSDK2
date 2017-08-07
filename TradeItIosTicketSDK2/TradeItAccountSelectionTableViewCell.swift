import UIKit

class TradeItAccountSelectionTableViewCell: UITableViewCell {
    func populate(withLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceEquityPresenter(linkedBrokerAccount)
        self.textLabel?.text = linkedBrokerAccount.getFormattedAccountName()

        self.detailTextLabel?.text = ""

        if let buyingPower = presenter.getFormattedBuyingPowerLabelWithTimestamp() {
            self.detailTextLabel?.text = "BUYING POWER: " + buyingPower
        }
    }
}
