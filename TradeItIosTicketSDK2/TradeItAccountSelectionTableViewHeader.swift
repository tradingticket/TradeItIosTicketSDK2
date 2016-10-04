import UIKit

class TradeItAccountSelectionTableViewHeader: UITableViewCell {

    @IBOutlet weak var brokerLabel: UILabel!
    
    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.brokerLabel.text = linkedBroker.linkedLogin.broker
    }
}
