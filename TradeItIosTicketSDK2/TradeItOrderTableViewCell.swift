import UIKit

class TradeItOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var orderTypeDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TradeItThemeConfigurator.configure(view: self)
    }
    
    func populate(withOrder order: TradeItOrderStatusDetails) {
        let orderPresenter = TradeItOrderStatusDetailsPresenter(order: order)
        self.symbolLabel?.text = orderPresenter.getSymbol()
        self.descriptionLabel?.text = orderPresenter.getFormattedDescription()
        self.expirationLabel.text = orderPresenter.getFormattedExpiration()
        self.orderTypeDescriptionLabel.text = orderPresenter.getFormattededOrderTypeDescription()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
