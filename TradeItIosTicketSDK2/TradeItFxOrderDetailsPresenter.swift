@objc public enum TradeItFxOrderExpiration: Int {
    case goodForDay
    case goodUntilCanceled
    case immediateOrCancel
    case fillOrKill
    case unknown
}

@objc public enum TradeItFxOrderPriceType: Int {
    case market
    case limit
    case stop
    case unknown
}

@objc public enum TradeItFxOrderAction: Int {
    case buy
    case sell
    case unknown
}

class TradeItFxOrderPriceTypePresenter {
    static let DEFAULT: TradeItFxOrderPriceType            = .market
    static let TYPES: [TradeItFxOrderPriceType]            = [.market, .limit, .stop]
    static let LIMIT_TYPES: [TradeItFxOrderPriceType]      = [.limit]
    static let STOP_TYPES: [TradeItFxOrderPriceType]       = [.stop]
    static let EXPIRATION_TYPES: [TradeItFxOrderPriceType] = [.limit, .stop]

    static func labels() -> [String] {
        return TYPES.map(labelFor)
    }

    static func labelFor(_ type: TradeItFxOrderPriceType) -> String {
        switch(type) {
        case .market: return "Market"
        case .limit: return "Limit"
        case .stop: return "Stop"
        case .unknown: return "Unknown"
        }
    }

    static func enumFor(_ type: String) -> TradeItFxOrderPriceType {
        switch(type) {
        case "Market": return .market
        case "Limit": return .limit
        case "Stop": return .stop
        default: return .unknown
        }
    }
}

class TradeItFxOrderActionPresenter {
    static let DEFAULT: TradeItFxOrderAction = .buy
    static let ACTIONS: [TradeItFxOrderAction] = [.buy, .sell]

    private static let buyDescription = "Buy"
    private static let sellDescription = "Sell"

    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }

    static func labelFor(_ type: TradeItFxOrderAction) -> String {
        switch(type) {
        case .buy: return buyDescription
        case .sell: return sellDescription
        case .unknown: return "Unknown"
        }
    }

    static func enumFor(_ type: String) -> TradeItFxOrderAction {
        switch(type) {
        case buyDescription: return .buy
        case sellDescription: return .sell
        default: return .unknown
        }
    }
}

class TradeItFxOrderExpirationPresenter {
    static let DEFAULT: TradeItFxOrderExpiration = .goodForDay
    static let ACTIONS: [TradeItFxOrderExpiration] = [.goodForDay, .goodUntilCanceled, .immediateOrCancel, .fillOrKill]

    private static let goodForDayDescription = "Good for day"
    private static let goodUntilCanceledDescription = "Good until canceled"
    private static let immediateOrCancelDescription = "Immediate or cancel"
    private static let fillOrKillDescription = "Fill or kill"

    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }

    static func labelFor(_ type: TradeItFxOrderExpiration) -> String {
        switch(type) {
        case .goodForDay: return goodForDayDescription
        case .goodUntilCanceled: return goodUntilCanceledDescription
        case .immediateOrCancel: return immediateOrCancelDescription
        case .fillOrKill: return fillOrKillDescription
        case .unknown : return "Unknown"
        }
    }

    static func enumFor(_ type: String) -> TradeItFxOrderExpiration {
        switch(type) {
        case goodForDayDescription: return .goodForDay
        case goodUntilCanceledDescription: return .goodUntilCanceled
        case immediateOrCancelDescription: return .immediateOrCancel
        case fillOrKillDescription: return .fillOrKill
        default: return .unknown
        }
    }
}
