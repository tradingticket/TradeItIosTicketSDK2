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

    let dateFormatter = NSDateFormatter()

    func updateSymbol(symbol: String?) {
        guard let symbol = symbol else { return }

        self.symbolButton.setTitle(symbol, forState: .Normal)
        clearQuote()
    }

    func updateQuote(quote: TradeItQuote?) {
        if let quote = quote {
            let presenter = TradeItQuotePresenter(quote)
            self.quoteLastPriceLabel.text = presenter.getLastPriceLabel()
            self.quoteChangeLabel.text = presenter.getChangeLabel()
            self.updatedAtLabel.text = "Updated at \(DateTimeFormatter.time())"
            
            self.quoteChangeLabel.textColor = presenter.getChangeLabelColor()
        }
        else {
            self.quoteLastPriceLabel.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }
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

}
