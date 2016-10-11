import TradeItIosEmsApi

class TradeItPortfolioFxPositionPresenter: TradeItPortfolioPositionPresenter {
    var fxPosition: TradeItFxPosition = TradeItFxPosition()

    override init(_ tradeItPortfolioPosition: TradeItPortfolioPosition) {
        if let fxPosition = tradeItPortfolioPosition.fxPosition {
            self.fxPosition = fxPosition
        }

        super.init(tradeItPortfolioPosition)
    }

    override func getFormattedSymbol() -> String {
        guard let symbol = self.tradeItPortfolioPosition.fxPosition?.symbol
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return symbol
    }
    
    override func getQuantity() -> Float? {
        return self.fxPosition.quantity as? Float
    }

    override func formatCurrency(currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
    }

    override func getFormattedQuantity() -> String {
        guard let quantity = getQuantity()
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return NumberFormatter.formatQuantity(quantity)
    }

    func getAveragePrice() -> String {
        guard let averagePrice = fxPosition.averagePrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(averagePrice)
    }

    func getTotalUnrealizedProfitAndLossBaseCurrency() -> String {
        guard let totalUnrealizedProfitAndLossBaseCurrency = fxPosition.totalUnrealizedProfitAndLossBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(totalUnrealizedProfitAndLossBaseCurrency)
    }
}
