class TradeItOrderDetailsPresenter {
    private var orderDetails: TradeItPreviewTradeOrderDetails

    init(orderDetails: TradeItPreviewTradeOrderDetails) {
        self.orderDetails = orderDetails
    }    
    
    func getOrderExpirationLabel() -> String {
        return TradeItOrderExpirationPresenter.labelFor(self.orderDetails.expirationType())
    }
    
    func getOrderActionLabel() -> String {
        return self.orderDetails.orderAction.capitalized
    }
}

class TradeItOrderPriceTypePresenter {
    static let DEFAULT: TradeItOrderPriceType            = .market
    static let TYPES: [TradeItOrderPriceType]            = [.market, .limit, .stopMarket, .stopLimit]
    static let LIMIT_TYPES: [TradeItOrderPriceType]      = [.limit, .stopLimit]
    static let STOP_TYPES: [TradeItOrderPriceType]       = [.stopLimit, .stopMarket]
    static let EXPIRATION_TYPES: [TradeItOrderPriceType] = [.limit, .stopMarket, .stopLimit]
    
    static func labels() -> [String] {
        return TYPES.map(labelFor)
    }
    
    static func labelFor(_ type: TradeItOrderPriceType) -> String {
        switch(type) {
        case .market: return "Market"
        case .limit: return "Limit"
        case .stopMarket: return "Stop Market"
        case .stopLimit: return "Stop Limit"
        case .unknown: return "Unknown"
        }
    }
    
    static func enumFor(_ type: String) -> TradeItOrderPriceType {
        switch(type) {
        case "Market": return .market
        case "Limit": return .limit
        case "Stop Market": return .stopMarket
        case "Stop Limit": return .stopLimit
        default: return .unknown
        }
    }
}

class TradeItOrderActionPresenter {
    static let DEFAULT: TradeItOrderAction = .buy
    static let ACTIONS: [TradeItOrderAction] = [.buy, .sell, .buyToCover, .sellShort]
    static let SELL_ACTIONS: [TradeItOrderAction] = [.sell, .sellShort]

    private static let buyDescription = "Buy"
    private static let sellDescription = "Sell"
    private static let buyToCoverDescription = "Buy to Cover"
    private static let sellShortDescription = "Sell Short"

    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }

    static func labelFor(_ type: TradeItOrderAction) -> String {
        switch(type) {
        case .buy: return buyDescription
        case .sell: return sellDescription
        case .buyToCover: return buyToCoverDescription
        case .sellShort: return sellShortDescription
        case .unknown: return "Unknown"
        }
    }
    
    static func enumFor(_ type: String) -> TradeItOrderAction {
        switch(type) {
        case buyDescription, "buy": return .buy
        case sellDescription, "sell": return .sell
        case buyToCoverDescription, "buyToCover": return .buyToCover
        case sellShortDescription, "sellShort": return .sellShort
        default: return .unknown
        }
    }
}

class TradeItOrderExpirationPresenter {
    static let DEFAULT: TradeItOrderExpiration = .goodForDay
    static let ACTIONS: [TradeItOrderExpiration] = [.goodForDay, .goodUntilCanceled]

    private static let goodForDayDescription = "Good for day"
    private static let goodUntilCanceledDescription = "Good until canceled"

    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }
    
    static func labelFor(_ type: TradeItOrderExpiration) -> String {
        switch(type) {
        case .goodForDay: return goodForDayDescription
        case .goodUntilCanceled: return goodUntilCanceledDescription
        case .unknown : return "Unknown"
        }
    }
    
    static func enumFor(_ type: String) -> TradeItOrderExpiration {
        switch(type) {
        case goodForDayDescription: return .goodForDay
        case goodUntilCanceledDescription: return .goodUntilCanceled
        default: return .unknown
        }
    }
}
