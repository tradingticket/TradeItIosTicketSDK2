class NumberFormatter: NSObject {
    private static let currencyFormatter = Foundation.NumberFormatter()
    private static let quantityFormatter = Foundation.NumberFormatter()
    
    static func formatCurrency(
        _ number: NSNumber,
        minimumFractionDigits: Int = 2,
        maximumFractionDigits: Int = 2,
        displayVariance: Bool = false,
        currencyCode: String? = TradeItPresenter.DEFAULT_CURRENCY_CODE
    ) -> String {
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currencyCode
        currencyFormatter.currencySymbol = overrideCurrencySymbol(forCurrencyCode: currencyCode)
        currencyFormatter.minimumFractionDigits = minimumFractionDigits
        currencyFormatter.maximumFractionDigits = maximumFractionDigits
        var formattedCurrency = currencyFormatter.string(from: number)
        if displayVariance,
            number.doubleValue > 0.0,
            let unwrappedFormattedCurrency = formattedCurrency {
            formattedCurrency = "+\(unwrappedFormattedCurrency)"
        }
        return formattedCurrency ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    static func formatQuantity(_ number: NSNumber, maxDecimalPlaces: Int = 2) -> String {
        quantityFormatter.numberStyle = .decimal
        quantityFormatter.minimumFractionDigits = 0
        quantityFormatter.maximumFractionDigits = maxDecimalPlaces
        return quantityFormatter.string(from: number) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatPercentage(_ number: NSNumber) -> String {
        let percentageFormatter = Foundation.NumberFormatter()
        percentageFormatter.positivePrefix = "+"
        percentageFormatter.negativePrefix = "-"
        percentageFormatter.numberStyle = .percent
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 2
        let percentage = number.floatValue / 100
        return percentageFormatter.string(from: NSNumber(value: percentage)) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatSimplePercentage(_ number: NSNumber) -> String {
        let percentageFormatter = Foundation.NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 2
        let percentage = number.floatValue / 100
        return percentageFormatter.string(from: NSNumber(value: percentage)) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    
    private static func overrideCurrencySymbol(forCurrencyCode currencyCode: String?) -> String? {
        switch currencyCode {
        case "SGD"?: return "S$"
        case ""?: return "" // To show no currency symbol
        default: return nil
        }
    }
}
