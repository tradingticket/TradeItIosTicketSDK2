import UIKit


// TODO: Remove?
class TradeItPortfolioAccountsTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var brokerNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withAccount account: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalancePresenterFactory.forTradeItLinkedBrokerAccount(account)
        self.accountNameLabel.text = account.getFormattedAccountName()
        self.brokerNameLabel.text = account.brokerName
        self.buyingPowerLabel.text = presenter.getFormattedBuyingPower()
        self.totalValueLabel.text = presenter.getFormattedTotalValueWithPercentage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.selectedIcon.isHidden = false
        }
        else {
            self.selectedIcon.isHidden = true
        }
        
    }
}
