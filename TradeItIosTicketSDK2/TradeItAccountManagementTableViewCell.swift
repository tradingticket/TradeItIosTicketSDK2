import UIKit

class TradeItAccountManagementTableViewCell: UITableViewCell {
    
    var selectedBrokerAccount: TradeItLinkedBrokerAccount!
    let accountSwitch = UISwitch()

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
        self.accessoryView = self.accountSwitch
        self.accountSwitch.addTarget(self, action: #selector(accountEnabledSwitchWasTapped(sender:)), for: UIControlEvents.valueChanged)
    }

    func populate(_ linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceEquityPresenter(linkedBrokerAccount)
        self.selectedBrokerAccount = linkedBrokerAccount
        self.accountSwitch.isOn = self.selectedBrokerAccount.isEnabled
        self.textLabel?.text = linkedBrokerAccount.getFormattedAccountName()

        self.detailTextLabel?.text = ""

        let buyingPower = presenter.getFormattedBuyingPower()

        if buyingPower != TradeItPresenter.MISSING_DATA_PLACEHOLDER {
            self.detailTextLabel?.text = "Buying power: " + buyingPower
        }
    }
    
    func accountEnabledSwitchWasTapped(sender: UISwitch!) {
            self.selectedBrokerAccount.isEnabled =  self.accountSwitch.isOn
    }
}
