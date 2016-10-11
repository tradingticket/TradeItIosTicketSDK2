import TradeItIosEmsApi

class TradeItPortfolioPositionPresenter {
    let tradeItPortfolioPosition: TradeItPortfolioPosition

    init(_ tradeItPortfolioPosition: TradeItPortfolioPosition) {
        self.tradeItPortfolioPosition = tradeItPortfolioPosition
    }
    
    func getFormattedSymbol() -> String {
        return TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    func getQuote() -> TradeItQuote? {
        return self.tradeItPortfolioPosition.quote
    }

    func getFormattedSpread() -> String {
        guard let quote = getQuote()
            , let high = quote.high as? Float
            , let low = quote.low as? Float
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(high - low)
    }

    func formatCurrency(currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency as Float)
    }

    func getFormattedAsk() -> String {
        guard let askPrice = getQuote()?.askPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(askPrice)
    }

    func getFormattedBid() -> String {
        guard let bidPrice = getQuote()?.bidPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(bidPrice)
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

    func getFormattedQuantity() -> String {
        return TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    func getQuantity() -> Float? {
        return nil
    }

    func getFormattedTotalReturn() -> String {
        return TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
}
