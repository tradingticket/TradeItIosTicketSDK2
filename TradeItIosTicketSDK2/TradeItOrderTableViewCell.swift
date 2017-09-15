import UIKit

class TradeItOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var orderTypeDescriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var symbolLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLeadingSpaceConstraint: NSLayoutConstraint!
    
    private static let LEADING_SPACE_ORDER_CELL = CGFloat(5.0)
    private static let LEADING_SPACE_GROUP_ORDER_CELL = CGFloat(15.0)
    
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
            self.symbolLeadingSpaceConstraint.constant = TradeItOrderTableViewCell.LEADING_SPACE_GROUP_ORDER_CELL
            self.descriptionLeadingSpaceConstraint.constant = TradeItOrderTableViewCell.LEADING_SPACE_GROUP_ORDER_CELL
        } else {
            self.symbolLeadingSpaceConstraint.constant = TradeItOrderTableViewCell.LEADING_SPACE_ORDER_CELL
            self.descriptionLeadingSpaceConstraint.constant = TradeItOrderTableViewCell.LEADING_SPACE_ORDER_CELL
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
