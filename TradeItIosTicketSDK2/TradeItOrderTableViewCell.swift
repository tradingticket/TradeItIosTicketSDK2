import UIKit

class TradeItOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var orderTypeDescriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var symbolLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLeadingSpaceConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TradeItThemeConfigurator.configure(view: self)
    }
    
    func populate(withOrder order: TradeItOrderStatusDetails, andOrderLeg orderLeg: TradeItOrderLeg, isGroupOrder: Bool = false) {
        let orderPresenter = TradeItOrderStatusDetailsPresenter(order: order, orderLeg: orderLeg)
        self.symbolLabel?.text = orderPresenter.getSymbol()
        self.descriptionLabel?.text = orderPresenter.getFormattedDescription()
        self.expirationLabel.text = orderPresenter.getFormattedExpiration()
        self.orderTypeDescriptionLabel.text = orderPresenter.getFormattededOrderTypeDescription()
        self.statusLabel.text = orderPresenter.getFormattedStatus()
        if isGroupOrder {
            self.symbolLeadingSpaceConstraint.constant = CGFloat(10.0)
            self.descriptionLeadingSpaceConstraint.constant = CGFloat(10.0)
        } else {
            self.symbolLeadingSpaceConstraint.constant = CGFloat(0.0)
            self.descriptionLeadingSpaceConstraint.constant = CGFloat(0.0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
