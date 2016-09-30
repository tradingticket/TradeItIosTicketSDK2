import TradeItIosEmsApi

class TradeItPortfolioEquityPositionPresenter: TradeItPortfolioPositionPresenter {
    let position: TradeItPosition

    override init(_ tradeItPortfolioPosition: TradeItPortfolioPosition) {
        position = tradeItPortfolioPosition.position
        super.init(tradeItPortfolioPosition)
    }

    override func getFormattedSymbol() -> String {
        return position.symbol
    }

    override func getQuantity() -> Float {
        return position.quantity as Float
    }

    override func getFormattedQuantity() -> String {
        return NumberFormatter.formatQuantity(getQuantity()) + (position.holdingType == "LONG" ? " shares": " short")
    }

    override func getFormattedTotalReturn() -> String {
        // QUESTION: Is it possible for totalGainLossDollar to be nil?
        return "\(returnPrefix())\(NumberFormatter.formatCurrency(position.totalGainLossDollar as Float))(\(returnPercent()))";
    }

    func returnPrefix() -> String {
        // QUESTION: I changed this a bit - does this look correct?
        if (position.totalGainLossDollar.floatValue > 0) {
            return "+"
        } else if position.totalGainLossDollar.floatValue < 0 {
            return "-"
        } else {
            return ""
        }
    }

    func returnPercent() -> String {
        if position.totalGainLossPercentage != nil {
            return NumberFormatter.formatPercentage(position.totalGainLossPercentage.floatValue);
        } else {
            return "N/A"
        }
    }

    func getCostBasis() -> String {
        return formatCurrency(position.costbasis)
    }

    func getLastPrice() -> String {
        return formatCurrency(position.lastPrice)
    }
}
