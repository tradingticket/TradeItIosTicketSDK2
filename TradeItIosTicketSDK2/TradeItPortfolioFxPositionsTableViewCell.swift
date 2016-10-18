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
    @IBOutlet weak var fxPositionsDetails: UIView!
    
    @IBOutlet weak var fxPositionDetailsHeightConstraint: NSLayoutConstraint!
    
    private var selectedPosition: TradeItPortfolioPosition?
    private var fxPositionsDetailsHeight = CGFloat(0.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.fxPositionsDetailsHeight = self.fxPositionDetailsHeightConstraint.constant
    }
    
    func populate(withPosition position: TradeItPortfolioPosition) {
        let presenter = TradeItPortfolioFxPositionPresenter(position)
        self.selectedPosition = position
        self.symbolLabelValue.text = presenter.getFormattedSymbol()
        self.quantityLabelValue.text = presenter.getFormattedQuantity()
        self.avgRateLabel.text = presenter.getAveragePrice()
        self.unrealizedPlLabel.text = presenter.getTotalUnrealizedProfitAndLossBaseCurrency()
        self.askLabelValue.text = presenter.getFormattedAsk()
        self.bidLabelValue.text = presenter.getFormattedBid()
        self.spreadLabelValue.text = presenter.getFormattedSpread()
    }
    
    func showPositionDetails(show: Bool) {
        if show {
            self.fxPositionsDetails.hidden = false
            self.fxPositionDetailsHeightConstraint.constant = self.fxPositionsDetailsHeight
            self.chevron.image = UIImage(named: "chevron_up")
        }
        else {
            self.fxPositionsDetails.hidden = true
            self.fxPositionDetailsHeightConstraint.constant = 0
            self.chevron.image = UIImage(named: "chevron_down")
        }
    }

}
