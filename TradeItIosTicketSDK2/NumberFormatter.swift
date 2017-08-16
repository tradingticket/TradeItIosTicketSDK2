extension NumberFormatter {
    private static let currencyFormatter = Foundation.NumberFormatter()
    private static let quantityFormatter = Foundation.NumberFormatter()
    private static let percentageFormatter = Foundation.NumberFormatter()
    
    static func formatCurrency(_ number: NSNumber, maximumFractionDigits: Int = 2, displayVariance: Bool = false, currencyCode: String?) -> String {
        let currencyCode = currencyCode ?? TradeItPresenter.DEFAULT_CURRENCY_CODE
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currencyCode
        currencyFormatter.currencySymbol = overrideCurrencySymbol(forCurrencyCode: currencyCode)
        if displayVariance {
            currencyFormatter.positivePrefix = "+" + currencyFormatter.currencySymbol
            currencyFormatter.negativePrefix = "-" + currencyFormatter.currencySymbol
        } else {
            currencyFormatter.positivePrefix = nil
            currencyFormatter.negativePrefix = nil
        }
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = maximumFractionDigits
        return currencyFormatter.string(from: number) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatQuantity(_ number: NSNumber) -> String {
        quantityFormatter.numberStyle = .decimal
        quantityFormatter.minimumFractionDigits = 0
        quantityFormatter.maximumFractionDigits = 2
        return quantityFormatter.string(from: number) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatPercentage(_ number: NSNumber) -> String {
        percentageFormatter.numberStyle = .percent
        percentageFormatter.positivePrefix = "+"
        percentageFormatter.negativePrefix = "-"
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 2
        let percentage = number.floatValue / 100
        return percentageFormatter.string(from: NSNumber(value: percentage)) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    private static func overrideCurrencySymbol(forCurrencyCode currencyCode: String) -> String? {
        switch currencyCode {
        case "SGD": return "S$"
        default: return nil
        }
    }
}
