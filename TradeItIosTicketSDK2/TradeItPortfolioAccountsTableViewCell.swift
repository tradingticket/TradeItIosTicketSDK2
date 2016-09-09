import UIKit

class TradeItPortfolioAccountsTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var brokerNameLabel: UILabel!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!

    func populate(withAccount account: TradeItAccountPortfolio) {
        self.accountNameLabel.text = account.accountName
        self.brokerNameLabel.text = account.brokerName
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
