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
    
    fileprivate var selectedPosition: TradeItPortfolioPosition?
    fileprivate var fxPositionsDetailsHeight = CGFloat(0.0)

    // TODO: These should be extracted to some kind of bundle asset provider
    fileprivate let chevronUpImage = UIImage(named: "chevron_up",
                                         in: Bundle(for: TradeItPortfolioFxPositionsTableViewCell.self),
                                         compatibleWith: nil)

    fileprivate let chevronDownImage = UIImage(named: "chevron_down",
                                           in: Bundle(for: TradeItPortfolioFxPositionsTableViewCell.self),
                                           compatibleWith: nil)

    
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
    
    func showPositionDetails(_ show: Bool) {
        if show {
            self.fxPositionsDetails.isHidden = false
            self.fxPositionDetailsHeightConstraint.constant = self.fxPositionsDetailsHeight
            self.chevron.image = chevronUpImage
        } else {
            self.fxPositionsDetails.isHidden = true
            self.fxPositionDetailsHeightConstraint.constant = 0
            self.chevron.image = chevronDownImage
        }
    }
}
