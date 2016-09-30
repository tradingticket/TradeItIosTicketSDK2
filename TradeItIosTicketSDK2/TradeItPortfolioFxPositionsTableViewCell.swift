import UIKit

class TradeItPortfolioFxPositionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var symbolLabelValue: UILabel!
    @IBOutlet weak var quantityLabelValue: UILabel!
    @IBOutlet weak var avgRateLabel: UILabel!
    @IBOutlet weak var unrealizedPlLabel: UILabel!
    @IBOutlet weak var chevron: UIImageView!
    @IBOutlet weak var askLabelValue: UILabel!
    @IBOutlet weak var bidLabelValue: UILabel!
    @IBOutlet weak var spreadLabelValue: UILabel!
    
    
    func populate(withPosition position: TradeItPortfolioPosition) {
        let presenter = TradeItPortfolioFxPositionPresenter(position)
        self.symbolLabelValue.text = presenter.getFormattedSymbol()
        self.quantityLabelValue.text = presenter.getFormattedQuantity()
        self.avgRateLabel.text = presenter.getAveragePrice()
        self.unrealizedPlLabel.text = presenter.getTotalUnrealizedProfitAndLossBaseCurrency()
        self.askLabelValue.text = presenter.getFormattedAsk()
        self.bidLabelValue.text = presenter.getFormattedBid()
        self.spreadLabelValue.text = presenter.getFormattedSpread()
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

}
