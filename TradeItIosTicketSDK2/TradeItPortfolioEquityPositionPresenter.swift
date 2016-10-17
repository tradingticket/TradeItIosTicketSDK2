import UIKit

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
        guard let totalGainLossDollars = self.position?.totalGainLossDollar
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return TradeItPresenter.indicator(totalGainLossDollars.doubleValue) + " " + "\(NumberFormatter.formatCurrency(totalGainLossDollars))(\(returnPercent()))";
    }
    
    func getFormattedTotalReturnColor() -> UIColor {
        guard let totalGainLossDollars = self.position?.totalGainLossDollar
            else { return UIColor.lightTextColor() }
        return TradeItPresenter.stockChangeColor(totalGainLossDollars.doubleValue)
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
    
    func getFormattedDayChange() -> String {
        guard let quote = getQuote()
            else {return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        let quotePresenter = TradeItQuotePresenter(quote)
        return quotePresenter.getChangeLabel()
    }
    
    func getFormattedDayChangeColor() -> UIColor {
        guard let change = self.getQuote()?.change
            else { return UIColor.lightTextColor() }
        return TradeItPresenter.stockChangeColor(change.doubleValue)
    }
    
    func getHoldingType() -> String? {
        return self.position?.holdingType
    }
}
