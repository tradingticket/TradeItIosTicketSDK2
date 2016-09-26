import UIKit

class TradeItPortfolioAccountsTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var brokerNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!

    func populate(withAccount account: TradeItLinkedBrokerAccount) {
        self.accountNameLabel.text = account.getFormattedAccountName()
        self.brokerNameLabel.text = account.brokerName
        self.buyingPowerLabel.text = account.getFormattedBuyingPower()
        self.totalValueLabel.text = account.getFormattedTotalValueWithPercentage()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.selectedIcon.hidden = false
        }
        else {
            self.selectedIcon.hidden = true
        }
        
    }
    
}
