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

    func getQuantity() -> Double? {
        return self.position?.quantity
    }

    func getFormattedQuantity() -> String {
        guard let holdingType = self.position?.holdingType
            , let quantity = getQuantity()
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }


        let holdingTypeSuffix = holdingType.caseInsensitiveCompare("LONG") == .orderedSame ? " shares" : " short"

        return NumberFormatter.formatQuantity(quantity) + holdingTypeSuffix
    }

    func getFormattedTotalReturn() -> String {
        guard let totalGainLossAbsolute = self.position?.totalGainLossAbsolute
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return "\(formatCurrency(totalGainLossAbsolute)) (\(returnPercent()))";
    }
    
    func getFormattedTotalReturnColor() -> UIColor {
        guard let totalGainLossAbsolute = self.position?.totalGainLossAbsolute
            else { return UIColor.lightText }
        return TradeItPresenter.stockChangeColor(totalGainLossAbsolute)
    }
    
    func returnPercent() -> String {
        guard let totalGainLossPercentage = self.position?.totalGainLossPercentage
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return NumberFormatter.formatPercentage(totalGainLossPercentage)
    }

    func getAvgCost() -> String {
        guard let cost = self.position?.costbasis, let quantity = getQuantity() , quantity != 0
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        let avgCost = cost / quantity
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
    
    func getFormattedDayReturn() -> String? {
        let quotePresenter = TradeItQuotePresenter(getCurrencyCode())
        return quotePresenter.formatChange(change: position?.todayGainLossAbsolute, percentChange: position?.todayGainLossPercentage)
    }
    
    func getFormattedDayChangeColor() -> UIColor {
        return TradeItPresenter.stockChangeColor(position?.todayGainLossAbsolute)
    }

    func getHoldingType() -> String? {
        return self.position?.holdingType
    }

    func getCurrencyCode() -> String {
        return self.position?.currencyCode ?? TradeItPresenter.DEFAULT_CURRENCY_CODE
    }
}
