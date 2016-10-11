import UIKit

class TradeItAccountSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabelValue: UILabel!
    
    func populate(withLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        
        self.accountNameLabel.text = linkedBrokerAccount.getFormattedAccountName()
        self.buyingPowerLabelValue.text = linkedBrokerAccount.getFormattedBuyingPower()
    }
}
