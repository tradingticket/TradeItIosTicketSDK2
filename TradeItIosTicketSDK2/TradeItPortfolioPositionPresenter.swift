import TradeItIosEmsApi

class TradeItPortfolioPositionPresenter {
    let tradeItPortfolioPosition: TradeItPortfolioPosition

    init(_ tradeItPortfolioPosition: TradeItPortfolioPosition) {
        self.tradeItPortfolioPosition = tradeItPortfolioPosition
    }
    
    func getFormattedSymbol() -> String {
        return "N/A"
    }

    func getQuote() -> TradeItQuote? {
        return self.tradeItPortfolioPosition.quote
    }

    func getFormattedSpread() -> String {
        guard let quote = getQuote() else { return "N/A" }
        let high = quote.high as Float
        let low = quote.low as Float
        return formatCurrency(high - low)
    }

    func formatCurrency(currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency as Float)
    }

    func getFormattedAsk() -> String {
        guard let quote = getQuote() else { return "N/A" }
        return formatCurrency(quote.askPrice)
    }

    func getFormattedBid() -> String {
        guard let quote = getQuote() else { return "N/A" }
        return formatCurrency(quote.bidPrice)
    }

    func getFormattedTotalValue() -> String {
        guard let quote = getQuote() else { return "N/A" }
        let total = getQuantity() * (quote.lastPrice as Float)
        return formatCurrency(total)
    }

    func getFormattedDayHighLow() -> String {
        guard let quote = getQuote() else { return "N/A" }
        let high = quote.high
        let low = quote.low
        return formatCurrency(low) + " - " + formatCurrency(high)
    }

    func getFormattedQuantity() -> String {
        return "N/A"
    }

    func getQuantity() -> Float {
        return 0.0
    }

    func getFormattedTotalReturn() -> String {
        return "N/A"
    }
}
