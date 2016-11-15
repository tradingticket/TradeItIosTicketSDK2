class NumberFormatter: NSObject {
    private static let formatter = Foundation.NumberFormatter()
    
    static func formatCurrency(_ number: NSNumber, maximumFractionDigits: Int = 2, currencyCode: String?) -> String {
        let currencyCode = currencyCode ?? TradeItPresenter.DEFAULT_CURRENCY_CODE
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.currencySymbol = overrideCurrencySymbol(forCurrencyCode: currencyCode)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: number) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatQuantity(_ number: NSNumber) -> String {
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: number) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatPercentage(_ number: NSNumber) -> String {
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let percentage = number.floatValue / 100
        return formatter.string(from: NSNumber(value: percentage)) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    private static func overrideCurrencySymbol(forCurrencyCode currencyCode: String) -> String? {
        switch currencyCode {
        case "SGD": return "S$"
        default: return nil
        }
    }
}
