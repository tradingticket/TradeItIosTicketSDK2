import TradeItIosEmsApi

class TradeItPortfolioEquityPositionPresenter: TradeItPortfolioPositionPresenter {
    var position: TradeItPosition?
    var tradeItPortfolioPosition: TradeItPortfolioPosition
    
    init(_ tradeItPortfolioPosition: TradeItPortfolioPosition) {
        self.tradeItPortfolioPosition = tradeItPortfolioPosition
        self.position = tradeItPortfolioPosition.position
    }

    func getFormattedSymbol() -> String {
        guard let symbol = self.position?.symbol
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        
        return symbol
    }

    func getQuantity() -> Float? {
        guard let quantity = self.position?.quantity
            else { return 0 }
        
        return quantity.floatValue
    }

    func getFormattedQuantity() -> String {
        guard let holdingType = self.position?.holdingType
            , let quantity = getQuantity()
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }


        let holdingTypeSuffix = holdingType.caseInsensitiveCompare("LONG") == .OrderedSame ? " shares" : " short"

        return NumberFormatter.formatQuantity(quantity) + holdingTypeSuffix
    }

    func getFormattedTotalReturn() -> String {
        guard let totalGainLossDollars = self.position?.totalGainLossDollar as? Float
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return "\(returnPrefix())\(NumberFormatter.formatCurrency(totalGainLossDollars))(\(returnPercent()))";
    }

    func returnPrefix() -> String {
        guard let totalGainLossDollar = self.position?.totalGainLossDollar
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
        guard let totalGainLossPercentage = self.position?.totalGainLossPercentage
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return NumberFormatter.formatPercentage(totalGainLossPercentage.floatValue);
    }

    func getCostBasis() -> String {
        guard let costBasis = self.position?.costbasis
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(costBasis)
    }

    func getLastPrice() -> String {
        guard let lastPrice = self.position?.lastPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(lastPrice)
    }
    
    func getQuote() -> TradeItQuote? {
        return self.tradeItPortfolioPosition.quote
    }
}
