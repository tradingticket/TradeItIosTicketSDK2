import UIKit

class TradeItPortfolioEquityPositionsTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabelValue: UILabel!
    @IBOutlet weak var quantityLabelValue: UILabel!
    @IBOutlet weak var lastPriceLabelValue: UILabel!
    @IBOutlet weak var avgCostLabelValue: UILabel!
    
    @IBOutlet weak var chevron: UIImageView!
    @IBOutlet weak var bidLabelValue: UILabel!
    @IBOutlet weak var askLabelValue: UILabel!
    @IBOutlet weak var dayLabelValue: UILabel!
    @IBOutlet weak var totalLabelValue: UILabel!
    @IBOutlet weak var totalReturnLabelValue: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var positionDetailsView: UIView!

    @IBOutlet weak var positionDetailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBuyHeight: NSLayoutConstraint!

    weak var delegate: TradeItPortfolioPositionsTableViewCellDelegate?

    fileprivate var selectedPosition: TradeItPortfolioPosition?
    fileprivate var positionDetailsHeight = CGFloat(0.0)
    fileprivate var buttonHeight =  CGFloat(0.0)

    // TODO: These should be extracted to some kind of bundle asset provider
    fileprivate let chevronUpImage = UIImage(named: "chevron_up",
                                         in: Bundle(for: TradeItPortfolioEquityPositionsTableViewCell.self),
                                         compatibleWith: nil)

    fileprivate let chevronDownImage = UIImage(named: "chevron_down",
                                           in: Bundle(for: TradeItPortfolioEquityPositionsTableViewCell.self),
                                           compatibleWith: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.positionDetailsHeight = self.positionDetailsHeightConstraint.constant
        self.buttonHeight = self.buttonBuyHeight.constant
    }

    func populate(withPosition position: TradeItPortfolioPosition) {
        self.selectedPosition = position
        let presenter = TradeItPortfolioEquityPositionPresenter(position)
        self.symbolLabelValue.text = presenter.getFormattedSymbol()
        self.avgCostLabelValue.text = presenter.getAvgCost()
        self.lastPriceLabelValue.text = presenter.getLastPrice()
        self.quantityLabelValue.text = presenter.getFormattedQuantity()
        self.bidLabelValue.text = presenter.getFormattedBid()
        self.askLabelValue.text = presenter.getFormattedAsk()
        self.dayLabelValue.text = presenter.getFormattedDayChange()
        self.dayLabelValue.textColor = presenter.getFormattedDayChangeColor()
        self.totalLabelValue.text = presenter.getFormattedTotalValue()
        self.totalReturnLabelValue.text = presenter.getFormattedTotalReturn()
        self.totalReturnLabelValue.textColor = presenter.getFormattedTotalReturnColor()

        self.updateTradeButtonVisibility()
    }

    func showPositionDetails(_ show: Bool) {
        if show {
            var buttonHeight = CGFloat(0.0)

            if self.selectedPosition?.position?.instrumentType() != TradeItInstrumentType.EQUITY_OR_ETF {
                buttonHeight = self.buttonHeight
            }

            self.positionDetailsView.isHidden = false
            self.positionDetailsHeightConstraint.constant = self.positionDetailsHeight - buttonHeight
            self.chevron.image = chevronUpImage
        } else {
            self.positionDetailsView.isHidden = true
            self.positionDetailsHeightConstraint.constant = 0
            self.chevron.image = chevronDownImage
        }
    }
    
    // MARK: private
    
    fileprivate func updateTradeButtonVisibility() {
        if self.selectedPosition?.position?.instrumentType() == TradeItInstrumentType.EQUITY_OR_ETF {
            self.buyButton.isHidden = false
            self.sellButton.isHidden = false
        } else {
            self.buyButton.isHidden = true
            self.sellButton.isHidden = true
        }
    }
    
    // MARK: IBAction
    
    @IBAction func buyButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(forPortFolioPosition: self.selectedPosition, orderAction: .buy)
    }
    
    @IBAction func sellButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(forPortFolioPosition: self.selectedPosition, orderAction: .sell)
    }
}

protocol TradeItPortfolioPositionsTableViewCellDelegate: class {
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?)
}
