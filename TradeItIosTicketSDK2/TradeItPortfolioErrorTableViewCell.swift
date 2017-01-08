import UIKit

class TradeItPortfolioErrorTableViewCell: UITableViewCell {
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var brokerNameLabel: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.brokerNameLabel.text = linkedBroker.linkedLogin.broker
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.selectedIcon.isHidden = false
        }
        else {
            self.selectedIcon.isHidden = true
        }
        
    }
}
