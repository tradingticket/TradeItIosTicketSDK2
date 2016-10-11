import TradeItIosEmsApi

class TradeItPortfolioEquityPositionPresenter: TradeItPortfolioPositionPresenter {
    var position: TradeItPosition = TradeItPosition()

    override init(_ tradeItPortfolioPosition: TradeItPortfolioPosition) {
        if let position = tradeItPortfolioPosition.position {
            self.position = position
        }
        super.init(tradeItPortfolioPosition)
    }

    override func getFormattedSymbol() -> String {
        guard let symbol = self.position.symbol
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        
        return symbol
    }

    override func getQuantity() -> Float? {
        guard let quantity = self.position.quantity
            else { return 0}
        
        return quantity.floatValue
    }

    override func getFormattedQuantity() -> String {
        var holdingType = TradeItPresenter.MISSING_DATA_PLACEHOLDER

        if self.position.holdingType != nil {
            holdingType = (self.position.holdingType == "LONG" ? " shares": " short")
        }
        return NumberFormatter.formatQuantity(getQuantity()!) + holdingType
    }

    override func getFormattedTotalReturn() -> String {
        guard let totalGainLossDollars = self.position.totalGainLossDollar
            else {return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        return "\(returnPrefix())\(NumberFormatter.formatCurrency(totalGainLossDollars as Float))(\(returnPercent()))";
    }

    func returnPrefix() -> String {
        guard let totalGainLossDollar = self.position.totalGainLossDollar
            else { return "" }
        if (totalGainLossDollar.floatValue > 0) {
            return "+"
        } else if totalGainLossDollar.floatValue < 0 {
            return "-"
        } else {
            return ""
        }
    }

    func returnPercent() -> String {
        guard let totalGainLossPercentage = self.position.totalGainLossPercentage
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return NumberFormatter.formatPercentage(totalGainLossPercentage.floatValue);
    }

    func getCostBasis() -> String {
        guard let costBasis = self.position.costbasis
            else {return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        return formatCurrency(costBasis)
    }

    func getLastPrice() -> String {
        guard let lastPrice = self.position.lastPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return formatCurrency(lastPrice)
    }
}
