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
        self.symbolLabelValue.text = position.getFormattedSymbol()
        self.quantityLabelValue.text = position.getFormattedQuantity()
        self.labelColumn1Value.text = self.getLabelColumn1Value(position)
        self.labelColumn2Value.text = self.getLabelColumn2Value(position)
        self.detailsValue1.text = self.getDetailsValue1(position)
        self.detailsValue2.text = self.getDetailsValue2(position)
        self.detailsValue3.text = self.getDetailsValue3(position)
        self.detailsValue4.text = self.getDetailsValue4(position)
        self.detailsValue5.text = self.getDetailsValue5(position)
        self.displayOrHideLabels(position)
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
    
    private func displayOrHideLabels(position: TradeItPortfolioPosition) {
        if position.fxPosition != nil {
            self.detailsLabel1.text = "Ask"
            self.detailsLabel2.text = "Spread"
            self.detailsLabel3.text = "Bid"
            self.detailsLabel4.hidden = true
            self.detailsLabel5.hidden = true
            self.detailsValue4.hidden = true
            self.detailsValue5.hidden = true
        }
        else {
            self.detailsLabel1.text = "Bid"
            self.detailsLabel2.text = "Total Value"
            self.detailsLabel3.text = "Ask"
            self.detailsLabel4.hidden = false
            self.detailsLabel5.hidden = false
            self.detailsValue4.hidden = false
            self.detailsValue5.hidden = false
        }
    }
    
    private func getLabelColumn1Value(position: TradeItPortfolioPosition) -> String {
        var labelColumn1Value = "N/A"
        if let position = position.position {
            labelColumn1Value = NumberFormatter.formatCurrency(position.costbasis as Float)
        }
        else if let fxPosition = position.fxPosition {
            labelColumn1Value = NumberFormatter.formatCurrency(fxPosition.averagePrice as Float, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
        }
        return labelColumn1Value
    }
    
    private func getLabelColumn2Value(position: TradeItPortfolioPosition) -> String {
        var labelColumn2Value = "N/A"
        if let position = position.position {
            labelColumn2Value = NumberFormatter.formatCurrency(position.lastPrice as Float)
        }
        else if let fxPosition = position.fxPosition {
            labelColumn2Value = NumberFormatter.formatCurrency(fxPosition.totalUnrealizedProfitAndLossBaseCurrency as Float)
        }
        return labelColumn2Value
    }
    
    private func getDetailsValue1(position: TradeItPortfolioPosition) -> String {
        var labelDetailsValue1 = "N/A"
        if position.position != nil {
            labelDetailsValue1 = position.getFormattedBid()
        }
        else if position.fxPosition != nil {
            labelDetailsValue1 = position.getFormattedAsk()
        }
        return labelDetailsValue1
    }
    
    private func getDetailsValue2(position: TradeItPortfolioPosition) -> String {
        var labelDetailsValue2 = "N/A"
        if position.position != nil {
            //Total Value
            labelDetailsValue2 = position.getFormattedTotalValue()
        }
        else if position.fxPosition != nil {
            labelDetailsValue2 = position.getFormattedSpread()
        }
        return labelDetailsValue2
    }
    
    private func getDetailsValue3(position: TradeItPortfolioPosition) -> String {
        var labelDetailsValue3 = "N/A"
        if position.position != nil {
            labelDetailsValue3 = position.getFormattedAsk()
        }
        else if position.fxPosition != nil {
            labelDetailsValue3 = position.getFormattedBid()
        }
        return labelDetailsValue3
    }
    
    private func getDetailsValue4(position: TradeItPortfolioPosition) -> String {
        var labelDetailsValue4 = "N/A"
        if position.position != nil {
            labelDetailsValue4 = position.getFormattedTotalReturn()
        }
        return labelDetailsValue4
    }
    
    private func getDetailsValue5(position: TradeItPortfolioPosition) -> String {
        var labelDetailsValue5 = "N/A"
        if position.position != nil {
            labelDetailsValue5 = position.getFormattedDayHighLow()
        }
        return labelDetailsValue5
    }


}
