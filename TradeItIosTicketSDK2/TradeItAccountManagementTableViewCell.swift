import UIKit

class TradeItAccountManagementTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var accountEnabledSwitch: UISwitch!
    var selectedBrokerAccount: TradeItLinkedBrokerAccount!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureTableCell(cell: self)
    }

    func populate(_ linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalancePresenterFactory.forTradeItLinkedBrokerAccount(linkedBrokerAccount)
        self.selectedBrokerAccount = linkedBrokerAccount
        self.accountEnabledSwitch.isOn = self.selectedBrokerAccount.isEnabled
        self.accountNameLabel.text = linkedBrokerAccount.getFormattedAccountName()
        self.buyingPowerLabel.text = presenter.getFormattedBuyingPower()
    }
    
    //MARK: IBAction
    @IBAction func accountEnabledSwitchWasTapped(_ sender: AnyObject) {
        self.selectedBrokerAccount.isEnabled =  accountEnabledSwitch.isOn
    }
}
