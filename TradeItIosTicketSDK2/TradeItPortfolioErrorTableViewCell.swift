import UIKit

class TradeItPortfolioErrorTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var brokerNameLabel: UILabel!
    
    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.brokerNameLabel.text = linkedBroker.linkedLogin.broker
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
