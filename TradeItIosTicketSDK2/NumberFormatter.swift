class NumberFormatter: NSObject {
    private static let currencyFormatter = Foundation.NumberFormatter()
    private static let quantityFormatter = Foundation.NumberFormatter()
    
    static func formatCurrency(
        _ number: Double,
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
        var formattedCurrency = currencyFormatter.string(for: number)
        if displayVariance,
            number > 0.0,
            let unwrappedFormattedCurrency = formattedCurrency {
            formattedCurrency = "+\(unwrappedFormattedCurrency)"
        }
        return formattedCurrency ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    static func formatQuantity(_ number: Double, minDecimalPlaces: Int = 0, maxDecimalPlaces: Int = 2) -> String {
        quantityFormatter.numberStyle = .decimal
        quantityFormatter.minimumFractionDigits = minDecimalPlaces
        quantityFormatter.maximumFractionDigits = maxDecimalPlaces
        return quantityFormatter.string(for: number) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatPercentage(_ number: Double) -> String {
        let percentageFormatter = Foundation.NumberFormatter()
        percentageFormatter.positivePrefix = "+"
        percentageFormatter.negativePrefix = "-"
        percentageFormatter.numberStyle = .percent
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 2
        let percentage = number / 100
        return percentageFormatter.string(from: NSNumber(value: percentage)) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    static func formatSimplePercentage(_ number: Double) -> String {
        let percentageFormatter = Foundation.NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 2
        let percentage = number / 100
        return percentageFormatter.string(for: percentage) ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    
    private static func overrideCurrencySymbol(forCurrencyCode currencyCode: String?) -> String? {
        switch currencyCode {
        case "SGD"?: return "S$"
        case ""?: return "" // To show no currency symbol
        default: return nil
        }
    }
}
