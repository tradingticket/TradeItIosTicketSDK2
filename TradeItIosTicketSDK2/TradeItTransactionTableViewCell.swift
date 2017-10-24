import UIKit

class TradeItTransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withTransaction transaction: TradeItTransaction) {
        // TODO
        self.transactionTypeLabel.text = transaction.type
        self.timestampLabel.text = transaction.date
        self.descriptionLabel.text = transaction.transactionDescription
        self.amountLabel.text = NumberFormatter.formatCurrency(transaction.price ?? 0)
    }
}
