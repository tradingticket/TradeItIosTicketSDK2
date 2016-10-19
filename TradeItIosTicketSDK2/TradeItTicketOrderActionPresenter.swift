public enum TradeItOrderAction {
    case Buy
    case Sell
    case BuyToCover
    case SellShort
}

class TradeItOrderActionPresenter {
    static let DEFAULT: TradeItOrderAction = .Buy
    static let ACTIONS: [TradeItOrderAction] = [.Buy, .Sell, .BuyToCover, .SellShort]

    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }

    static func labelFor(type: TradeItOrderAction) -> String {
        switch(type) {
        case .Buy: return "Buy"
        case .Sell: return "Sell"
        case .BuyToCover: return "Buy to Cover"
        case .SellShort: return "Sell Short"
        }
    }

    static func enumFor(type: String) -> TradeItOrderAction {
        switch(type) {
        case "Buy": return .Buy
        case "Sell": return .Sell
        case "Buy to Cover": return .BuyToCover
        case "Sell Short": return .SellShort
        default: return DEFAULT
        }
    }
}
