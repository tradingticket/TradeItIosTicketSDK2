import TradeItIosEmsApi

protocol TradeItPortfolioPositionPresenter {
    func getQuote() -> TradeItQuote?
    func getQuantity() -> Float?
    func getFormattedSymbol() -> String
}

extension TradeItPortfolioPositionPresenter {
    
    func getFormattedBid() -> String {
        guard let bidPrice = getQuote()?.bidPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return formatCurrency(bidPrice)
    }
    
    func formatCurrency(currency: NSNumber) -> String {
                return NumberFormatter.formatCurrency(currency as Float)
    }
    
    func getFormattedAsk() -> String {
        guard let askPrice = getQuote()?.askPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(askPrice)
    }
    
    func getFormattedSpread() -> String {
        guard let quote = getQuote()
            , let high = quote.high as? Float
            , let low = quote.low as? Float
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(high - low)
    }
    
    func getFormattedTotalValue() -> String {
        guard let lastPrice = getQuote()?.lastPrice as? Float
            , let quantity = getQuantity()
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        let total = quantity * lastPrice

        return formatCurrency(total)
    }

    func getFormattedDayHighLow() -> String {
        guard let quote = getQuote()
            , let high = quote.high
            , let low = quote.low
        else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(low) + " - " + formatCurrency(high)
    }
}

class TradeItPortfolioPositionPresenterFactory {
    
    static func forTradeItPortfolioPosition(tradeItPortfolioPosition: TradeItPortfolioPosition) -> TradeItPortfolioPositionPresenter {
        if tradeItPortfolioPosition.position != nil {
            return TradeItPortfolioEquityPositionPresenter(tradeItPortfolioPosition)
        } else if tradeItPortfolioPosition.fxPosition != nil {
            return TradeItPortfolioFxPositionPresenter(tradeItPortfolioPosition)
        } else {
            return TradeItPortfolioDefaultPositionPresenter(tradeItPortfolioPosition)
        }
    }
}

class TradeItPortfolioDefaultPositionPresenter: TradeItPortfolioEquityPositionPresenter{
}
