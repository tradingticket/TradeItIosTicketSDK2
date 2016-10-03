import TradeItIosEmsApi
import UIKit

class TradeItSymbolView: UIView {
    @IBOutlet weak var symbolButton: UIButton!
    @IBOutlet weak var quoteLastPriceLabel: UILabel!
    @IBOutlet weak var quoteChangeLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var quoteActivityIndicator: UIView!

    enum ActivityIndicatorState {
        case LOADING
        case LOADED
    }

    static let INDICATOR_UP = "▲"
    static let INDICATOR_DOWN = "▼"
    let dateFormatter = NSDateFormatter()

    func updateSymbol(symbol: String?) {
        guard let symbol = symbol else { return }

        self.symbolButton.setTitle(symbol, forState: .Normal)
        clearQuote()
    }

    func updateQuote(quote: TradeItQuote) {
        self.quoteLastPriceLabel.text = NumberFormatter.formatCurrency(quote.lastPrice)
        self.quoteChangeLabel.text = indicator(quote.change.doubleValue) + " " +
            NumberFormatter.formatCurrency(quote.change, currencyCode: "") +
            " (" + NumberFormatter.formatPercentage(quote.pctChange) + ")"
        self.updatedAtLabel.text = "Updated at \(DateTimeFormatter.time())"

        self.quoteChangeLabel.textColor = stockChangeColor(quote.change.doubleValue)
    }

    func updateQuoteActivity(state: ActivityIndicatorState) {
        switch state {
        case .LOADING:
            quoteActivityIndicator.hidden = false

            quoteLastPriceLabel.hidden = true
            quoteChangeLabel.hidden = true
        case .LOADED:
            quoteActivityIndicator.hidden = true

            quoteLastPriceLabel.hidden = false
            quoteChangeLabel.hidden = false
        }
    }

    private func clearQuote() {
        self.quoteLastPriceLabel.text = nil
        self.quoteChangeLabel.text = nil
        self.updatedAtLabel.text = nil
    }

    private func indicator(value: Double) -> String {
        if value > 0.0 {
            return TradeItSymbolView.INDICATOR_UP
        } else if value < 0 {
            return TradeItSymbolView.INDICATOR_DOWN
        } else {
            return ""
        }
    }

    private func stockChangeColor(value: Double) -> UIColor {
        if value > 0.0 {
            return UIColor.tradeItMoneyGreenColor()
        } else if value < 0 {
            return UIColor.tradeItDeepRoseColor()
        } else {
            return UIColor.lightTextColor()
        }
    }
}
