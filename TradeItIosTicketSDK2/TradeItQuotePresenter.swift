import UIKit

class TradeItQuotePresenter: NSObject {
    let currencyCode: String
    let minimumFractionDigits: Int
    let maximumFractionDigits: Int

    init(_ currencyCode: String? = TradeItPresenter.DEFAULT_CURRENCY_CODE, minimumFractionDigits: Int = 2, maximumFractionDigits: Int = 3) {
        self.currencyCode = currencyCode ?? TradeItPresenter.DEFAULT_CURRENCY_CODE
        self.minimumFractionDigits = minimumFractionDigits
        self.maximumFractionDigits = maximumFractionDigits
    }

    func formatCurrency(_ value: Double?) -> String? {
        guard let value = value, value != 0 else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return NumberFormatter.formatCurrency(
            value,
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits,
            currencyCode: currencyCode
        )
    }

    func formatChange(change: Double?, percentChange: Double?) -> String? {
        var result = ""

        if let change = change, change != 0 {
            result = NumberFormatter.formatCurrency(
                change,
                minimumFractionDigits: minimumFractionDigits,
                maximumFractionDigits: maximumFractionDigits,
                currencyCode: self.currencyCode
            )
        }

        if let percentChange = percentChange, percentChange != 0 {
            result += " (" + NumberFormatter.formatPercentage(percentChange) + ")"
        }

        return result
    }

    func formatTimestamp(_ timestamp: String?) -> String {
        return timestamp ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    static func numberToDecimalNumber(_ value: Double?) -> NSDecimalNumber? {
        guard let value = value else { return nil }
        return NSDecimalNumber(decimal: Decimal(value))
    }

    static func getChangeLabelColor(changeValue: Double?) -> UIColor {
        guard let change = changeValue else { return TradeItSDK.theme.textColor }
        return TradeItPresenter.stockChangeColor(change)
    }
}
