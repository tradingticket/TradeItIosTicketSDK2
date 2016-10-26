import UIKit

class TradeItSymbolView: UIView {
    @IBOutlet weak var symbolButton: UIButton!
    @IBOutlet weak var quoteLastPriceLabel: UILabel!
    @IBOutlet weak var quoteChangeLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var quoteActivityIndicator: UIView!

    enum ActivityIndicatorState {
        case loading
        case loaded
    }

    let dateFormatter = DateFormatter()

    func updateSymbol(_ symbol: String?) {
        guard let symbol = symbol else { return }

        self.symbolButton.setTitle(symbol, for: UIControlState())
        clearQuote()
    }

    func updateQuote(_ quote: TradeItQuote?) {
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

    func updateQuoteActivity(_ state: ActivityIndicatorState) {
        switch state {
        case .loading:
            quoteActivityIndicator.isHidden = false

            quoteLastPriceLabel.isHidden = true
            quoteChangeLabel.isHidden = true
        case .loaded:
            quoteActivityIndicator.isHidden = true

            quoteLastPriceLabel.isHidden = false
            quoteChangeLabel.isHidden = false
        }
    }

    fileprivate func clearQuote() {
        self.quoteLastPriceLabel.text = nil
        self.quoteChangeLabel.text = nil
        self.updatedAtLabel.text = nil
    }

}
