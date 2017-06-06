import UIKit

class TradeItQuotePresenter: NSObject {
    let tradeItQuote: TradeItQuote
    let currencyCode: String
    init(_ tradeItQuote: TradeItQuote, _ currencyCode: String? = TradeItPresenter.DEFAULT_CURRENCY_CODE) {
        self.tradeItQuote = tradeItQuote
        self.currencyCode = currencyCode ?? TradeItPresenter.DEFAULT_CURRENCY_CODE
    }
    
    func getLastPriceLabelText() -> String {
        guard let lastPrice = self.tradeItQuote.lastPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return NumberFormatter.formatCurrency(lastPrice, maximumFractionDigits: 3, currencyCode: self.currencyCode)
    }
    
    func getTimestampLabelText() -> String {
        return self.tradeItQuote.dateTime ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
    }
    
    func getLastPriceValue() -> NSDecimalNumber {
        guard let lastPrice = self.tradeItQuote.lastPrice
            else { return 0.0 }
        return NSDecimalNumber(decimal: lastPrice.decimalValue)
    }

    func getChangeLabelText() -> String {
        var changeValue = TradeItPresenter.MISSING_DATA_PLACEHOLDER
        var pctChangeValue = TradeItPresenter.MISSING_DATA_PLACEHOLDER
        
        if let change = self.tradeItQuote.change {
            changeValue = NumberFormatter.formatCurrency(change, maximumFractionDigits: 3, currencyCode: self.currencyCode)
        }
        
        if let pctChange = self.tradeItQuote.pctChange {
            pctChangeValue = NumberFormatter.formatPercentage(pctChange)
        }
        
        
        return changeValue +
            " (" + pctChangeValue + ")"
    }
    
    func getChangeLabelColor() -> UIColor {
        guard let change = self.tradeItQuote.change
            else { return UIColor.lightText }
        return TradeItPresenter.stockChangeColor(change.doubleValue)
    }

}
