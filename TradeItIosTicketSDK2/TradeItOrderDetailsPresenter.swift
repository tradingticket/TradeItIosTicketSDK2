class TradeItOrderDetailsPresenter {

    private var orderDetails: TradeItPreviewTradeOrderDetails

    init(orderDetails: TradeItPreviewTradeOrderDetails) {
        self.orderDetails = orderDetails
    }    
    
    func getOrderExpirationLabel() -> String {
        return TradeItOrderExpirationPresenter.labelFor(self.orderDetails.expirationType())
    }
    
    func getOrderActionLabel() -> String {
        return self.orderDetails.orderAction.capitalizedString
    }
    
}

class TradeItOrderPriceTypePresenter {
    static let DEFAULT: TradeItOrderPriceType            = .Market
    static let TYPES: [TradeItOrderPriceType]            = [.Market, .Limit, .StopMarket, .StopLimit]
    static let LIMIT_TYPES: [TradeItOrderPriceType]      = [.Limit, .StopLimit]
    static let STOP_TYPES: [TradeItOrderPriceType]       = [.StopLimit, .StopMarket]
    static let EXPIRATION_TYPES: [TradeItOrderPriceType] = [.Limit, .StopMarket, .StopLimit]
    
    static func labels() -> [String] {
        return TYPES.map(labelFor)
    }
    
    static func labelFor(type: TradeItOrderPriceType) -> String {
        switch(type) {
        case .Market: return "Market"
        case .Limit: return "Limit"
        case .StopMarket: return "Stop Market"
        case .StopLimit: return "Stop Limit"
        case .Unknown: return "Unknown"
        }
    }
    
    static func enumFor(type: String) -> TradeItOrderPriceType {
        switch(type) {
        case "Market": return .Market
        case "Limit": return .Limit
        case "Stop Market": return .StopMarket
        case "Stop Limit": return .StopLimit
        default: return .Unknown
        }
    }
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
        case .Unknown: return "Unknown"
        }
    }
    
    static func enumFor(type: String) -> TradeItOrderAction {
        switch(type) {
        case "Buy": return .Buy
        case "Sell": return .Sell
        case "Buy to Cover": return .BuyToCover
        case "Sell Short": return .SellShort
        default: return .Unknown
        }
    }
}

class TradeItOrderExpirationPresenter {
    static let DEFAULT: TradeItOrderExpiration = .GoodForDay
    static let ACTIONS: [TradeItOrderExpiration] = [.GoodForDay, .GoodUntilCanceled]

    static func labels() -> [String] {
        return ACTIONS.map(labelFor)
    }
    
    static func labelFor(type: TradeItOrderExpiration) -> String {
        switch(type) {
        case .GoodForDay: return "Good for day"
        case .GoodUntilCanceled: return "Good until canceled"
        case .Unknown : return "Unknown"
        }
    }
    
    static func enumFor(type: String) -> TradeItOrderExpiration {
        switch(type) {
        case "Good for day": return .GoodForDay
        case "Good until canceled": return .GoodUntilCanceled
        default: return .Unknown
        }
    }
}
