import UIKit

class TradeItBrokerManagementTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        let presenter = TradeItLinkedBrokerPresenter(linkedBroker: linkedBroker)
        self.textLabel?.text = presenter.getFormattedBrokerLabel()
        self.detailTextLabel?.text = presenter.getFormattedBrokerAccountsLabel()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
