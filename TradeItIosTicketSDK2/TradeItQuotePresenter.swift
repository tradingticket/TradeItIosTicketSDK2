import UIKit

class TradeItQuotePresenter: NSObject {

    var tradeItQuote: TradeItQuote?
    
    init(_ tradeItQuote: TradeItQuote) {
        self.tradeItQuote = tradeItQuote
    }
    
    func getLastPriceLabel() -> String {
        guard let lastPrice = self.tradeItQuote?.lastPrice
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }
        return NumberFormatter.formatCurrency(lastPrice, currencyCode: TradeItPresenter.DEFAULT_CURRENCY_CODE)
    }
    
    func getLastPriceValue() -> NSDecimalNumber {
        guard let lastPrice = self.tradeItQuote?.lastPrice
            else { return 0.0 }
        return NSDecimalNumber(decimal: lastPrice.decimalValue)
    }

    func getChangeLabel() -> String {
        var changeValue = TradeItPresenter.MISSING_DATA_PLACEHOLDER
        var pctChangeValue = TradeItPresenter.MISSING_DATA_PLACEHOLDER
        
        if let change = self.tradeItQuote?.change {
            changeValue = TradeItPresenter.indicator(change.doubleValue) + " " + NumberFormatter.formatCurrency(change, currencyCode: "")
        }
        
        if let pctChange = self.tradeItQuote?.pctChange {
            pctChangeValue = NumberFormatter.formatPercentage(pctChange)
        }
        
        
        return changeValue +
            " (" + pctChangeValue + ")"
    }
    
    func getChangeLabelColor() -> UIColor {
        guard let change = self.tradeItQuote?.change
            else { return UIColor.lightText }
        return TradeItPresenter.stockChangeColor(change.doubleValue)
    }

}
