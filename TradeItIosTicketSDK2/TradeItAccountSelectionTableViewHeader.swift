import UIKit

class TradeItAccountSelectionTableViewHeader: UITableViewCell {

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureTableHeader(header: self)
        self.backgroundColor = TradeItSDK.theme.tableHeaderBackgroundColor
        self.textLabel?.textColor = TradeItSDK.theme.tableHeaderTextColor
        //self.accessoryView?.tintColor = TradeItSDK.theme.interactivePrimaryColor
        //self.accessoryView?.backgroundColor = TradeItSDK.theme.interactiveSecondaryColor
    }
    
    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.textLabel?.text = linkedBroker.brokerName
    }
}
