class NumberFormatter: NSObject {
    fileprivate static let formatter = Foundation.NumberFormatter()

    static func formatCurrency(_ number: NSNumber) -> String {
        return NumberFormatter.formatCurrency(number, maximumFractionDigits: 2)
    }
    
    static func formatCurrency(_ number: NSNumber, maximumFractionDigits: Int) -> String {
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: number) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatCurrency(_ number: NSNumber, currencyCode: String) -> String {
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
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
}
