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
    var baseSymbol: String?
    var quoteSymbol: String?
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
            self.baseSymbol = String(baseSymbol)
            self.quoteSymbol = String(quoteSymbol)
        }
    }

    private func clearSymbol() {
        _symbol = nil
        baseSymbol = nil
        quoteSymbol = nil
    }
}
