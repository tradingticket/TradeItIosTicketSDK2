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

    func getQuantity() -> NSNumber? {
        return self.position?.quantity
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

    func getAvgCost() -> String {
        guard let cost = self.position?.costbasis, quantity = getQuantity() where quantity != 0
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        let avgCost = cost.floatValue/quantity.floatValue
        return formatCurrency(avgCost)
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
}
