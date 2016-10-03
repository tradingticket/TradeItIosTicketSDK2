enum TradeItOrderPriceType {
    case Market
    case Limit
    case StopMarket
    case StopLimit
}

class TradeItOrderPriceTypePresenter {
    static let DEFAULT_TYPE: TradeItOrderPriceType = .Market
    static let TYPES: [TradeItOrderPriceType] = [.Market, .Limit, .StopMarket, .StopLimit]
    static let LIMIT_TYPES = [TradeItOrderPriceType.Limit, TradeItOrderPriceType.StopLimit]
    static let STOP_TYPES = [TradeItOrderPriceType.StopLimit, TradeItOrderPriceType.StopMarket]
    static let EXPIRATION_TYPES = [TradeItOrderPriceType.Limit, TradeItOrderPriceType.StopMarket, TradeItOrderPriceType.StopLimit]

    static func labels() -> [String] {
        return TYPES.map(labelFor)
    }

    static func labelFor(type: TradeItOrderPriceType) -> String {
        switch(type) {
        case .Market: return "Market"
        case .Limit: return "Limit"
        case .StopMarket: return "Stop Market"
        case .StopLimit: return "Stop Limit"
        }
    }

    static func enumFor(type: String) -> TradeItOrderPriceType {
        switch(type) {
        case "Market": return .Market
        case "Limit": return .Limit
        case "Stop Market": return .StopMarket
        case "Stop Limit": return .StopLimit
        default: return DEFAULT_TYPE
        }
    }
}
