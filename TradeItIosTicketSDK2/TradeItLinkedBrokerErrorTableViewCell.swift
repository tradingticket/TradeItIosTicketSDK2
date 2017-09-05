import UIKit

class TradeItLinkedBrokerErrorTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }
    
    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        guard let error = linkedBroker.error else { return }
        if error.isAccountLinkDelayedError() {
            self.textLabel?.text = linkedBroker.brokerName
            let shortMessage = error.shortMessage ?? "Activation in Progress"
            self.detailTextLabel?.text = shortMessage + ". Tap to refresh status."
        } else if error.requiresRelink() {
            self.textLabel?.text = "Relink Broker"
            self.detailTextLabel?.text = "The link with \(linkedBroker.brokerName) failed. Tap to relink."
        } else if error.requiresAuthentication() {
            self.textLabel?.text = "Account Information"
            self.detailTextLabel?.text = "Could not get the latest data. Tap to retry."
        } else {
            self.textLabel?.text = "Unknown Failure"
            self.detailTextLabel?.text = "Failed to fetch accounts. Tap to retry."
        }

        let warningImage = UIImage(
            named: "warning",
            in: Bundle(for: TradeItLinkedBrokerErrorTableViewCell.self),
            compatibleWith: nil
        )
        self.accessoryView = UIImageView(image: warningImage)
    }
    
}
