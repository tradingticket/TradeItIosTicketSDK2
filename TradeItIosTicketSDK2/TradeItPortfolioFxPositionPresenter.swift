import TradeItIosEmsApi

class TradeItPortfolioFxPositionPresenter: TradeItPortfolioPositionPresenter {
    let fxPosition: TradeItFxPosition

    override init(_ tradeItPortfolioPosition: TradeItPortfolioPosition) {
        fxPosition = tradeItPortfolioPosition.fxPosition
        super.init(tradeItPortfolioPosition)
    }

    override func getFormattedSymbol() -> String {
        return self.tradeItPortfolioPosition.fxPosition.symbol
    }
    
    override func getQuantity() -> Float {
        return self.fxPosition.quantity as Float
    }

    override func formatCurrency(currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
    }

    override func getFormattedQuantity() -> String {
        return NumberFormatter.formatQuantity(getQuantity())
    }

    func getAveragePrice() -> String {
        return formatCurrency(fxPosition.averagePrice)
    }

    func getTotalUnrealizedProfitAndLossBaseCurrency() -> String {
        return formatCurrency(fxPosition.totalUnrealizedProfitAndLossBaseCurrency)
    }
}
