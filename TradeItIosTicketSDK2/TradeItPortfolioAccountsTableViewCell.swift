import UIKit

class TradeItPortfolioAccountsTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var brokerNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!

    override func awakeFromNib() {
        self.accountNameLabel.textColor = TradeItTheme.textColor
        self.brokerNameLabel.textColor = TradeItTheme.textColor
        self.buyingPowerLabel.textColor = TradeItTheme.textColor
        self.totalValueLabel.textColor = TradeItTheme.textColor
        // TODO: Configure selectedIcon to fit theme
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
