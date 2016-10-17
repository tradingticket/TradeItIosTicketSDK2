import UIKit

class TradeItPortfolioEquityPositionsTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabelValue: UILabel!
    @IBOutlet weak var quantityLabelValue: UILabel!
    @IBOutlet weak var costLabelValue: UILabel!
    @IBOutlet weak var lastPriceLabelValue: UILabel!
    
    @IBOutlet weak var chevron: UIImageView!
    
    @IBOutlet weak var bidLabelValue: UILabel!
    @IBOutlet weak var askLabelValue: UILabel!
    @IBOutlet weak var dayLabelValue: UILabel!
    @IBOutlet weak var totalLabelValue: UILabel!
    @IBOutlet weak var totalReturnLabelValue: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    
    weak var delegate: TradeItPortfolioPositionsTableViewCellDelegate?
    
    private var selectedPosition: TradeItPortfolioPosition!
    
    func populate(withPosition position: TradeItPortfolioPosition) {
        self.selectedPosition = position
        let presenter = TradeItPortfolioEquityPositionPresenter(position)
        self.symbolLabelValue.text = presenter.getFormattedSymbol()
        self.costLabelValue.text = presenter.getCostBasis()
        self.lastPriceLabelValue.text = presenter.getLastPrice()
        self.quantityLabelValue.text = presenter.getFormattedQuantity()
        self.bidLabelValue.text = presenter.getFormattedBid()
        self.askLabelValue.text = presenter.getFormattedAsk()
        self.dayLabelValue.text = presenter.getFormattedDayHighLow()
        self.totalLabelValue.text = presenter.getFormattedTotalValue()
        self.totalReturnLabelValue.text = presenter.getFormattedTotalReturn()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.chevron.image = UIImage(named: "chevron_up")
        }
        else {
            self.chevron.image = UIImage(named: "chevron_down")
        }
    }
    
    @IBAction func buyButtonWasTapped(sender: AnyObject) {
        let order = TradeItOrder()
        order.action = TradeItOrderAction.Buy
        order.linkedBrokerAccount = self.selectedPosition.linkedBrokerAccount
        order.symbol = self.selectedPosition.position?.symbol
        self.delegate?.buyButtonWasTappedWith(order: order)
    }
    
    @IBAction func sellButtonWasTapped(sender: AnyObject) {
        let order = TradeItOrder()
        order.action = TradeItOrderAction.Sell
        order.linkedBrokerAccount = self.selectedPosition.linkedBrokerAccount
        order.symbol = self.selectedPosition.position?.symbol
        self.delegate?.sellButtonWasTappedWith(order: order)
    }
    
}

protocol TradeItPortfolioPositionsTableViewCellDelegate: class {
    func buyButtonWasTappedWith(order order: TradeItOrder)
    func sellButtonWasTappedWith(order order: TradeItOrder)
}
