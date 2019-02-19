import UIKit

class TradeItPortfolioEquityPositionsTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabelValue: UILabel!
    @IBOutlet weak var quantityLabelValue: UILabel!
    @IBOutlet weak var lastPriceLabelValue: UILabel!
    @IBOutlet weak var avgCostLabelValue: UILabel!
    
    @IBOutlet weak var chevron: UIImageView!
    @IBOutlet weak var proxyVoteImg: UIImageView!
    
    @IBOutlet weak var dayReturnLabel: UILabel!
    @IBOutlet weak var totalReturnLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var bidAskLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var positionDetailsStackView: UIView!

    @IBOutlet weak var dayReturnView: UIView!
    @IBOutlet weak var totalReturnView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    weak var delegate: TradeItPortfolioPositionsTableViewCellDelegate?

    private var selectedPosition: TradeItPortfolioPosition?

    // TODO: These should be extracted to some kind of bundle asset provider
    private let chevronUpImage = UIImage(named: "chevron_up",
                                         in: Bundle(for: TradeItPortfolioEquityPositionsTableViewCell.self),
                                         compatibleWith: nil)

    private let chevronDownImage = UIImage(named: "chevron_down",
                                           in: Bundle(for: TradeItPortfolioEquityPositionsTableViewCell.self),
                                           compatibleWith: nil)
    
    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    internal func populate(withPosition position: TradeItPortfolioPosition, showAverageCost: Bool) {
        self.selectedPosition = position
        let presenter = TradeItPortfolioEquityPositionPresenter(position)
        self.symbolLabelValue.text = presenter.getFormattedSymbol()
        self.avgCostLabelValue.text = showAverageCost ? presenter.getAvgCost() : ""
        self.lastPriceLabelValue.text = presenter.getLastPrice()
        self.quantityLabelValue.text = presenter.getFormattedQuantity()

        if let dayReturn = presenter.getFormattedDayReturn(), dayReturn != "" {
            self.dayReturnLabel.text = dayReturn
            self.dayReturnLabel.textColor = presenter.getFormattedDayChangeColor()
            self.dayReturnView.isHidden = false
        } else {
            self.dayReturnView.isHidden = true
        }
        
        if presenter.getFormattedTotalReturn() != TradeItPresenter.MISSING_DATA_PLACEHOLDER {
            self.totalReturnLabel.text = presenter.getFormattedTotalReturn()
            self.totalReturnLabel.textColor = presenter.getFormattedTotalReturnColor()
            self.totalReturnView.isHidden = false
        } else {
            self.totalReturnView.isHidden = true
        }

        
        self.totalValueLabel.text = presenter.getFormattedTotalValue()

        self.bidAskLabel.text = "\(presenter.getFormattedBid()) / \(presenter.getFormattedAsk())"

        self.updateTradeButtonVisibility()
        
        self.updateProxyVoteImageVisibility()
    }

    internal func showPositionDetails(_ show: Bool) {
        self.positionDetailsStackView.isHidden = !show
        self.chevron.image = show ? chevronUpImage : chevronDownImage
        TradeItThemeConfigurator.configure(view: self.chevron)
    }

    internal func showSpinner() {
        self.activityIndicator.startAnimating()
    }
    
    internal func hideSpinner() {
        self.activityIndicator.stopAnimating()
    }
    
    // MARK: IBAction
    
    @IBAction func buyButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(forPortFolioPosition: self.selectedPosition, orderAction: .buy)
    }
    
    @IBAction func sellButtonWasTapped(_ sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(forPortFolioPosition: self.selectedPosition, orderAction: .sell)
    }
    
    @objc func tappedProxyVote() {
        self.delegate?.proxyVoteWasTapped(forPortFolioPosition: self.selectedPosition)
    }


    // MARK: private

    private func updateTradeButtonVisibility() {
        if self.selectedPosition?.position?.instrumentType() == TradeItPositionInstrumentType.EQUITY_OR_ETF {
            self.buyButton.isHidden = false
            self.sellButton.isHidden = false
        } else {
            self.buyButton.isHidden = true
            self.sellButton.isHidden = true
        }
    }
    
    private func updateProxyVoteImageVisibility() {
        guard let isProxyVoteEligible = self.selectedPosition?.position?.isProxyVoteEligible, isProxyVoteEligible else {
            self.proxyVoteImg.isHidden = true
            return
        }
        self.proxyVoteImg.isHidden = false
        let tapProxyVote = UITapGestureRecognizer(target: self, action: #selector(TradeItPortfolioEquityPositionsTableViewCell.tappedProxyVote))
        self.proxyVoteImg.addGestureRecognizer(tapProxyVote)
        self.proxyVoteImg.isUserInteractionEnabled = true
    }
}

protocol TradeItPortfolioPositionsTableViewCellDelegate: class {
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?)
    func proxyVoteWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?)
}
