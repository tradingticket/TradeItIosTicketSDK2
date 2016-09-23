import UIKit

class TradeItBrokerManagementTableViewCell: UITableViewCell {

    @IBOutlet weak var brokerLabel: UILabel!
    @IBOutlet weak var brokerAccountsLabel: UILabel!

    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        let presenter = TradeItLinkedBrokerPresenter(linkedBroker: linkedBroker)
        self.brokerLabel.text = presenter.getFormattedBrokerLibelle()
        self.brokerAccountsLabel.text = presenter.getFormattedBrokerAccountsLabel()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
