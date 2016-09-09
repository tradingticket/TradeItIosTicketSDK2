import UIKit

class TradeItPortfolioAccountsTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var brokerNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!

    func populate(withAccount account: TradeItLinkedBrokerAccount) {
        self.accountNameLabel.text = account.accountName
        self.brokerNameLabel.text = account.brokerName
        self.buyingPowerLabel.text = getFormattedBuyingPower(account)
        self.totalValueLabel.text = getFormattedTotalValue(account)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: private methods
    
    private func getFormattedBuyingPower(account: TradeItLinkedBrokerAccount) -> String{
        if let balance = account.balance {
            return NumberFormatter.formatCurrency(balance.buyingPower)
        }
        
        else if let fxBalance = account.fxBalance {
            return NumberFormatter.formatCurrency(fxBalance.buyingPowerBaseCurrency)
        }
        
        else {
            return "N/A"
        }
    }
    
    private func getFormattedTotalValue(account: TradeItLinkedBrokerAccount) -> String{
        if let balance = account.balance {
            return NumberFormatter.formatCurrency(balance.totalValue)
        }
            
        else if let fxBalance = account.fxBalance {
            return NumberFormatter.formatCurrency(fxBalance.totalValueBaseCurrency)
        }
            
        else {
            return "N/A"
        }
    }
}
