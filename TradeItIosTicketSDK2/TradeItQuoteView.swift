import TradeItIosEmsApi
import UIKit

class TradeItQuoteView: UIView {
    @IBOutlet weak var symbolButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var buyingPowerLabel: UILabel!
    @IBOutlet weak var quoteLastPriceLabel: UILabel!
    @IBOutlet weak var quoteChangeLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!

    let indicator_up = "▲"
    let indicator_down = "▼"
    let dateFormatter = NSDateFormatter()

    func updateSymbol(symbol: String) {
        self.symbolButton.setTitle(symbol, forState: .Normal)
    }

    func updateBrokerAccount(brokerAccount: TradeItLinkedBrokerAccount) {
        self.buyingPowerLabel.text = NumberFormatter.formatCurrency(brokerAccount.balance.buyingPower)
    }

    func updateQuote(quote: TradeItQuote) {
        self.quoteLastPriceLabel.text = NumberFormatter.formatCurrency(quote.lastPrice)
        self.quoteChangeLabel.text = indicator(quote.change.doubleValue) + " " +
            NumberFormatter.formatCurrency(quote.change, currencyCode: "") +
            " (" + NumberFormatter.formatPercentage(quote.pctChange) + ")"
        self.updatedAtLabel.text = "Updated at \(DateTimeFormatter.time())"

        self.quoteChangeLabel.textColor = stockChangeColor(quote.change.doubleValue)
    }

    private func indicator(value: Double) -> String {
        if value > 0.0 {
            return indicator_down
        } else if value < 0 {
            return indicator_down
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
