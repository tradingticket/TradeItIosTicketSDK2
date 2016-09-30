enum TradeItOrderType {
    case Market
    case Limit
    case StopMarket
    case StopLimit
}

class TradeItOrderTypePresenter {
    static let DEFAULT_TYPE: TradeItOrderType = .Market
    static let TYPES: [TradeItOrderType] = [.Market, .Limit, .StopMarket, .StopLimit]
    static let LIMIT_TYPES = [TradeItOrderType.Limit, TradeItOrderType.StopLimit]
    static let STOP_TYPES = [TradeItOrderType.StopLimit, TradeItOrderType.StopMarket]
    static let EXPIRATION_TYPES = [TradeItOrderType.Limit, TradeItOrderType.StopMarket, TradeItOrderType.StopLimit]

    static func labels() -> [String] {
        return TYPES.map(labelFor)
    }

    static func labelFor(type: TradeItOrderType) -> String {
        switch(type) {
        case .Market: return "Market"
        case .Limit: return "Limit"
        case .StopMarket: return "Stop Market"
        case .StopLimit: return "Stop Limit"
        }
    }

    static func enumFor(type: String) -> TradeItOrderType {
        switch(type) {
        case "Market": return .Market
        case "Limit": return .Limit
        case "Stop Market": return .StopMarket
        case "Stop Limit": return .StopLimit
        default: return DEFAULT_TYPE
        }
    }
}
