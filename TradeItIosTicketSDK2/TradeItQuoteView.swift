import TradeItIosEmsApi
import UIKit

class TradeItQuoteView: UIView {
    @IBOutlet weak var symbolButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var availableDescriptionLabel: UILabel!
    @IBOutlet weak var quoteLastPriceLabel: UILabel!
    @IBOutlet weak var quoteChangeLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var quoteActivityIndicator: UIView!

    enum PresentationMode {
        case BUYING_POWER
        case SHARES_OWNED
    }

    enum ActivityIndicatorState {
        case LOADING
        case LOADED
    }

    let indicator_up = "▲"
    let indicator_down = "▼"
    let dateFormatter = NSDateFormatter()
    var brokerAccount: TradeItLinkedBrokerAccount?
    var presentationMode = PresentationMode.BUYING_POWER

    func updateSymbol(symbol: String) {
        self.symbolButton.setTitle(symbol, forState: .Normal)
    }

    func updatePresentationMode(presentationMode: PresentationMode) {
        self.presentationMode = presentationMode
        updateAvailableLabels()
    }

    func updateBrokerAccount(brokerAccount: TradeItLinkedBrokerAccount) {
        self.brokerAccount = brokerAccount
        updateAvailableLabels()
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
        case .LOADED:
            quoteActivityIndicator.hidden = true
            quoteLastPriceLabel.hidden = false
        }
    }

    private func updateAvailableLabels() {
        switch presentationMode {
        case .BUYING_POWER:
            guard let brokerAccount = brokerAccount else { return }
            self.availableLabel.text = NumberFormatter.formatCurrency(brokerAccount.balance.buyingPower)
            self.availableDescriptionLabel.text = "Buying Power"
        case .SHARES_OWNED:
            self.availableLabel.text = "None lol"
            self.availableDescriptionLabel.text = "Shares Owned"
        }
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
