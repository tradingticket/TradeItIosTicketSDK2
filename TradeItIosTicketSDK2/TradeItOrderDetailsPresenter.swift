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
    
    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }
    
    static func labelFor(_ type: TradeItOrderAction) -> String {
        switch(type) {
        case .buy: return "Buy"
        case .sell: return "Sell"
        case .buyToCover: return "Buy to Cover"
        case .sellShort: return "Sell Short"
        case .unknown: return "Unknown"
        }
    }
    
    static func enumFor(_ type: String) -> TradeItOrderAction {
        switch(type) {
        case "Buy": return .buy
        case "Sell": return .sell
        case "Buy to Cover": return .buyToCover
        case "Sell Short": return .sellShort
        default: return .unknown
        }
    }
}

class TradeItOrderExpirationPresenter {
    static let DEFAULT: TradeItOrderExpiration = .goodForDay
    static let ACTIONS: [TradeItOrderExpiration] = [.goodForDay, .goodUntilCanceled]

    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }
    
    static func labelFor(_ type: TradeItOrderExpiration) -> String {
        switch(type) {
        case .goodForDay: return "Good for day"
        case .goodUntilCanceled: return "Good until canceled"
        case .unknown : return "Unknown"
        }
    }
    
    static func enumFor(_ type: String) -> TradeItOrderExpiration {
        switch(type) {
        case "Good for day": return .goodForDay
        case "Good until canceled": return .goodUntilCanceled
        default: return .unknown
        }
    }
}
