@objc public enum TradeItFxOrderExpiration: Int {
    case goodForDay
    case goodUntilCanceled
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

//class TradeItFxOrderDetailsPresenter {
//    private var orderDetails: TradeItPreviewTradeOrderDetails
//
//    init(orderDetails: TradeItPreviewTradeOrderDetails) {
//        self.orderDetails = orderDetails
//    }
//
//    func getOrderExpirationLabel() -> String {
//        return TradeItOrderExpirationPresenter.labelFor(self.orderDetails.expirationType())
//    }
//
//    func getOrderActionLabel() -> String {
//        return self.orderDetails.orderAction.capitalized
//    }
//}

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

//class TradeItOrderExpirationPresenter {
//    static let DEFAULT: TradeItOrderExpiration = .goodForDay
//    static let ACTIONS: [TradeItOrderExpiration] = [.goodForDay, .goodUntilCanceled]
//
//    private static let goodForDayDescription = "Good for day"
//    private static let goodUntilCanceledDescription = "Good until canceled"
//
//    static func labels() -> [String] {
//        return ACTIONS.map(labelFor)
//    }
//
//    static func labelFor(_ type: TradeItOrderExpiration) -> String {
//        switch(type) {
//        case .goodForDay: return goodForDayDescription
//        case .goodUntilCanceled: return goodUntilCanceledDescription
//        case .unknown : return "Unknown"
//        }
//    }
//
//    static func enumFor(_ type: String) -> TradeItOrderExpiration {
//        switch(type) {
//        case goodForDayDescription: return .goodForDay
//        case goodUntilCanceledDescription: return .goodUntilCanceled
//        default: return .unknown
//        }
//    }
//}
