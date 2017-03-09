import UIKit

class TradeItPortfolioLinkedBrokerErrorTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func populate(withError error: TradeItErrorResult) {
        let messages = (error.longMessages as? [String]) ?? []
        let message = messages.joined(separator: ". ")

        self.titleLabel.text = error.shortMessage
        self.descriptionLabel.text = message
    }
}
