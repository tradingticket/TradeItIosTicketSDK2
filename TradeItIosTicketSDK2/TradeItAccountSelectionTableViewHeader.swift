import UIKit

class TradeItAccountSelectionTableViewHeader: UITableViewCell {
    @IBOutlet weak var brokerLabel: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureTableHeader(header: self)
        self.backgroundColor = TradeItSDK.theme.tableHeaderBackgroundColor
        self.brokerLabel.textColor = TradeItSDK.theme.tableHeaderTextColor
    }
    
    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.brokerLabel.text = linkedBroker.linkedLogin.broker
    }
}
