import UIKit

class TradeItTransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withTransaction transaction: TradeItTransaction, andAccountBasecurrency accountBaseCurrency: String) {
        let presenter = TradeItTransactionPresenter(transaction, currencyCode: accountBaseCurrency)
        self.transactionTypeLabel.text = presenter.getTransactionTypeLabel()
        self.timestampLabel.text = transaction.date
        self.descriptionLabel.text = presenter.getDescriptionLabel()
        self.amountLabel.text = presenter.getAmountLabel()
        self.amountLabel.textColor = presenter.getAmountLabelColor()
    }
}
