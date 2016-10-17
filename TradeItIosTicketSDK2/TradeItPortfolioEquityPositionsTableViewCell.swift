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
    
    private var selectedPosition: TradeItPortfolioPosition?
    
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
        
        self.performButtonsEnability()
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
    
    // MARK: private
    
    private func performButtonsEnability() {
        if self.selectedPosition?.position?.instrumentType() == TradeItInstrumentType.EQUITY_OR_ETF {
            self.buyButton.hidden = false
            self.sellButton.hidden = false
        }
        else {
            self.buyButton.hidden = true
            self.sellButton.hidden = true
        }
    }
    
    // MARK: IBAction
    
    @IBAction func buyButtonWasTapped(sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(forPortFolioPosition: self.selectedPosition, orderAction: TradeItOrderAction.Buy)
    }
    
    @IBAction func sellButtonWasTapped(sender: AnyObject) {
        self.delegate?.tradeButtonWasTapped(forPortFolioPosition: self.selectedPosition, orderAction: TradeItOrderAction.Sell)
    }
    
}

protocol TradeItPortfolioPositionsTableViewCellDelegate: class {
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?)
}
