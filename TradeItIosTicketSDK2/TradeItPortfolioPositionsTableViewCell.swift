import UIKit

class TradeItPortfolioPositionsTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabelValue: UILabel!
    @IBOutlet weak var quantityLabelValue: UILabel!
    @IBOutlet weak var labelColumn1Value: UILabel!
    @IBOutlet weak var labelColumn2Value: UILabel!
    @IBOutlet weak var chevron: UIImageView!
    
    
    @IBOutlet weak var detailsLabel1: UILabel!
    @IBOutlet weak var detailsLabel2: UILabel!
    @IBOutlet weak var detailsLabel3: UILabel!
    @IBOutlet weak var detailsLabel4: UILabel!
    @IBOutlet weak var detailsLabel5: UILabel!
    
    @IBOutlet weak var detailsValue1: UILabel!
    @IBOutlet weak var detailsValue2: UILabel!
    @IBOutlet weak var detailsValue3: UILabel!
    @IBOutlet weak var detailsValue4: UILabel!
    @IBOutlet weak var detailsValue5: UILabel!
    
    
    func populate(withPosition position: TradeItPortfolioPosition) {
        let presenter = TradeItPortfolioPositionPresenter.forPortfolioPosition(position)
        self.symbolLabelValue.text = presenter.getFormattedSymbol()
        self.quantityLabelValue.text = presenter.getFormattedQuantity()
        self.labelColumn1Value.text = self.getLabelColumn1Value(presenter)
        self.labelColumn2Value.text = self.getLabelColumn2Value(presenter)
        self.detailsValue1.text = self.getDetailsValue1(presenter)
        self.detailsValue2.text = self.getDetailsValue2(presenter)
        self.detailsValue3.text = self.getDetailsValue3(presenter)
        self.detailsValue4.text = self.getDetailsValue4(presenter)
        self.detailsValue5.text = self.getDetailsValue5(presenter)
        self.displayOrHideLabels(presenter)
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
    
    //MARK: private methods
    
    private func displayOrHideLabels(presenter: TradeItPortfolioPositionPresenter) {
        switch presenter {
        case is TradeItPortfolioPositionEquityPresenter:
            self.detailsLabel1.text = "Ask"
            self.detailsLabel2.text = "Spread"
            self.detailsLabel3.text = "Bid"
            self.detailsLabel4.hidden = true
            self.detailsLabel5.hidden = true
            self.detailsValue4.hidden = true
            self.detailsValue5.hidden = true
        default:
            self.detailsLabel1.text = "Bid"
            self.detailsLabel2.text = "Total Value"
            self.detailsLabel3.text = "Ask"
            self.detailsLabel4.hidden = false
            self.detailsLabel5.hidden = false
            self.detailsValue4.hidden = false
            self.detailsValue5.hidden = false
        }
    }
    
    private func getLabelColumn1Value(presenter: TradeItPortfolioPositionPresenter) -> String {
        switch presenter {
        case let equityPositionPresenter as TradeItPortfolioPositionEquityPresenter:
            return equityPositionPresenter.getCostBasis()
        case let fxPositionPresenter as TradeItPortfolioPositionFXPresenter:
            return fxPositionPresenter.getAveragePrice()
        default:
            return "N/A"
        }
    }
    
    private func getLabelColumn2Value(presenter: TradeItPortfolioPositionPresenter) -> String {
        switch presenter {
        case let equityPositionPresenter as TradeItPortfolioPositionEquityPresenter:
            return equityPositionPresenter.getLastPrice()
        case let fxPositionPresenter as TradeItPortfolioPositionFXPresenter:
            return fxPositionPresenter.getTotalUnrealizedProfitAndLossBaseCurrency()
        default:
            return "N/A"
        }
    }
    
    private func getDetailsValue1(presenter: TradeItPortfolioPositionPresenter) -> String {
        switch presenter {
        case let equityPositionPresenter as TradeItPortfolioPositionEquityPresenter:
            return equityPositionPresenter.getFormattedBid()
        case let fxPositionPresenter as TradeItPortfolioPositionFXPresenter:
            return fxPositionPresenter.getFormattedAsk()
        default:
            return "N/A"
        }
    }
    
    private func getDetailsValue2(presenter: TradeItPortfolioPositionPresenter) -> String {
        switch presenter {
        case let equityPositionPresenter as TradeItPortfolioPositionEquityPresenter:
            return equityPositionPresenter.getFormattedTotalValue()
        case let fxPositionPresenter as TradeItPortfolioPositionFXPresenter:
            return fxPositionPresenter.getFormattedSpread()
        default:
            return "N/A"
        }
    }
    
    private func getDetailsValue3(presenter: TradeItPortfolioPositionPresenter) -> String {
        switch presenter {
        case let equityPositionPresenter as TradeItPortfolioPositionEquityPresenter:
            return equityPositionPresenter.getFormattedAsk()
        case let fxPositionPresenter as TradeItPortfolioPositionFXPresenter:
            return fxPositionPresenter.getFormattedBid()
        default:
            return "N/A"
        }
    }
    
    private func getDetailsValue4(presenter: TradeItPortfolioPositionPresenter) -> String {
        switch presenter {
        case let equityPositionPresenter as TradeItPortfolioPositionEquityPresenter:
            return equityPositionPresenter.getFormattedTotalReturn()
        default:
            return "N/A"
        }
    }
    
    private func getDetailsValue5(presenter: TradeItPortfolioPositionPresenter) -> String {
        switch presenter {
        case let equityPositionPresenter as TradeItPortfolioPositionEquityPresenter:
            return equityPositionPresenter.getFormattedDayHighLow()
        default:
            return "N/A"
        }
    }
}
