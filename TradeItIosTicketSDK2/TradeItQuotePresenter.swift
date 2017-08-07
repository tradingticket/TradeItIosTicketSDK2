import UIKit

class TradeItQuotePresenter: NSObject {
    let currencyCode: String
    let minimumFractionDigits: Int
    let maximumFractionDigits: Int

    init(_ currencyCode: String? = TradeItPresenter.DEFAULT_CURRENCY_CODE, minimumFractionDigits: Int = 2, maximumFractionDigits: Int = 2) {
        self.currencyCode = currencyCode ?? TradeItPresenter.DEFAULT_CURRENCY_CODE
        self.minimumFractionDigits = minimumFractionDigits
        self.maximumFractionDigits = maximumFractionDigits
    }

    func formatCurrency(_ value: NSNumber?) -> String? {
        guard let value = value else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return NumberFormatter.formatCurrency(
            value,
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits,
            currencyCode: currencyCode
        )
    }

    func formatChange(change: NSNumber?, percentChange: NSNumber?) -> String? {
        var result = ""

        if let change = change {
            result = NumberFormatter.formatCurrency(change, currencyCode: self.currencyCode)
        }

        if let percentChange = percentChange {
            result += " (" + NumberFormatter.formatPercentage(percentChange) + ")"
        }

        return result
    }

    func formatTimestamp(_ timestamp: String?) -> String {
        return timestamp ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }

    static func numberToDecimalNumber(_ value: NSNumber?) -> NSDecimalNumber? {
        guard let value = value else { return nil }
        return NSDecimalNumber(decimal: value.decimalValue)
    }

    static func getChangeLabelColor(changeValue: NSNumber?) -> UIColor {
        guard let change = changeValue else { return UIColor.darkText }
        return TradeItPresenter.stockChangeColor(change.doubleValue)
    }
}
