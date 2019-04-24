protocol TradeItPortfolioPositionPresenter {
    func getQuote() -> TradeItQuote?
    func getQuantity() -> NSNumber?
    func getFormattedSymbol() -> String
    func getHoldingType() -> String?
    func getCurrencyCode() -> String
}

extension TradeItPortfolioPositionPresenter {
    func getFormattedBid() -> String {
        guard let bidPrice = getQuote()?.bidPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return formatCurrency(bidPrice)
    }

    func formatCurrency(_ currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency, currencyCode: getCurrencyCode())
    }

    func getFormattedAsk() -> String {
        guard let askPrice = getQuote()?.askPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(askPrice)
    }

    func getFormattedSpread() -> String {
        guard let quote = getQuote()
            , let high = quote.high?.floatValue
            , let low = quote.low?.floatValue
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(NSNumber(value: high - low))
    }

    func getFormattedTotalValue() -> String {
        guard let lastPrice = getQuote()?.lastPrice?.floatValue
            , let quantity = getQuantity()?.floatValue
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        let total = quantity * lastPrice

        return formatCurrency(NSNumber(value: total))
    }

    func getFormattedDayHighLow() -> String {
        guard let quote = getQuote()
            , let high = quote.high
            , let low = quote.low
        else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(low) + " - " + formatCurrency(high)
    }
}
