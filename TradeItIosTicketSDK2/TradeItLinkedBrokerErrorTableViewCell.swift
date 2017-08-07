import UIKit

class TradeItLinkedBrokerErrorTableViewCell: UITableViewCell {
    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        guard let error = linkedBroker.error else {
            return
        }
        if error.isAccountLinkDelayedError() {
            self.textLabel?.text = linkedBroker.brokerName
            let shortMessage = error.shortMessage ?? "Activation in Progress"
            self.detailTextLabel?.text = shortMessage + ". Tap to refresh status."
        } else if error.requiresRelink() {
            self.textLabel?.text = "Relink Broker"
            self.detailTextLabel?.text = "The link with \(linkedBroker.brokerName) failed. Tap to relink."
        } else if error.requiresAuthentication() {
            self.textLabel?.text = "Authentication Failed"
            self.detailTextLabel?.text = "Failed to create a session. Tap to retry."
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
