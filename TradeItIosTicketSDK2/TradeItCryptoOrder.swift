@objc public class TradeItCryptoOrder: TradeItOrder {
    var quantityType: OrderQuantityType? // TODO: Set default based off capabilities

    var quantitySymbol: String? {
        get {
            switch quantityType {
            case .some(.baseCurrency): return baseSymbol
            case .some(.quoteCurrency): return quoteSymbol
            default: return nil
            }
        }
    }

    private var _baseSymbol: String?
    var baseSymbol: String? {
        get {
            return _baseSymbol
        }
    }

    private var _quoteSymbol: String?
    var quoteSymbol: String? {
        get {
            return _quoteSymbol
        }
    }

    var _symbol: String?
    override public var symbol: String? {
        get {
            return _symbol
        }

        set(newValue) {
            guard let symbolPair = newValue?.split(separator: "/"),
                let baseSymbol = symbolPair.first,
                let quoteSymbol = symbolPair.last,
                symbolPair.count == 2
                else {
                    clearSymbol()
                    return
                }
            _symbol = newValue
            self._baseSymbol = String(baseSymbol)
            self._quoteSymbol = String(quoteSymbol)
        }
    }

    private func clearSymbol() {
        _symbol = nil
        _baseSymbol = nil
        _quoteSymbol = nil
    }
}
