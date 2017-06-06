class TradeItOrderDetailsPresenter {

    private var orderDetails: TradeItPreviewTradeOrderDetails

    init(orderDetails: TradeItPreviewTradeOrderDetails) {
        self.orderDetails = orderDetails
    }    
    
    func getOrderExpirationLabel(_ broker: String?) -> String {
        return TradeItOrderExpirationPresenter.labelFor(orderExpiration: self.orderDetails.expirationType(), broker: broker)
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
    
    static func labels(broker: String?) -> [String] {
        guard let broker = broker else {
            return TYPES.map(labelFor)
        }
        // This is specific to Cimb, but should be generalized to return only broker supported types: https://www.pivotaltracker.com/story/show/146699267
        return (broker == "Cimb") ? [.limit].map(labelFor) : TYPES.map(labelFor)
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

    private static let buyDescription = "Buy"
    private static let sellDescription = "Sell"
    private static let buyToCoverDescription = "Buy to Cover"
    private static let sellShortDescription = "Sell Short"

    static func labels(broker: String?) -> [String] {
        guard let broker = broker else {
            return ACTIONS.map(labelFor)
        }
        // This is specific to Cimb, but should be generalized to return only broker supported action types: https://www.pivotaltracker.com/story/show/146699267
        return (broker == "Cimb") ? [.buy, .sell].map(labelFor) : ACTIONS.map(labelFor)
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
        case buyDescription: return .buy
        case sellDescription: return .sell
        case buyToCoverDescription: return .buyToCover
        case sellShortDescription: return .sellShort
        default: return .unknown
        }
    }
}

class TradeItOrderExpirationPresenter {
    static let DEFAULT: TradeItOrderExpiration = .goodForDay
    static let ACTIONS: [TradeItOrderExpiration] = [.goodForDay, .goodUntilCanceled]

    private static let goodForDayDescription = "Good for day"
    private static let goodUntilCanceledDescription = "Good until canceled"
    private static let goodForDayDescriptionCimb = "Day"
    private static let goodUntilCanceledDescriptionCimb = "Good Till Maximum"
    
    
    static func labels(_ order: TradeItOrder) -> [String] {
        let defaultActions = ACTIONS.map { (orderExpiration: TradeItOrderExpiration) -> String in
            labelFor(orderExpiration: orderExpiration, broker: nil)
        }
        
        guard let broker = order.linkedBrokerAccount?.brokerName else {
            return defaultActions
        }
        // This is specific to Cimb, but should be generalized to return only broker supported types: https://www.pivotaltracker.com/story/show/146699267
        return (broker == "Cimb") ? [goodForDayDescriptionCimb, goodUntilCanceledDescriptionCimb] : defaultActions
    }
    
    static func labelFor(_ order: TradeItOrder) -> String {
        return labelFor(orderExpiration: order.expiration, broker: order.linkedBrokerAccount?.brokerName)
    }
    
    static func labelFor(orderExpiration: TradeItOrderExpiration, broker: String?) -> String {
        var goodForDay = goodForDayDescription
        var goodUntilCanceled = goodUntilCanceledDescription
        if broker == "Cimb" {
            goodForDay = goodForDayDescriptionCimb
            goodUntilCanceled = goodUntilCanceledDescriptionCimb
        }
        switch(orderExpiration) {
        case .goodForDay: return goodForDay
        case .goodUntilCanceled: return goodUntilCanceled
        case .unknown : return "Unknown"
        }
    }
    
    static func enumFor(_ type: String) -> TradeItOrderExpiration {
        switch(type) {
        case goodForDayDescription: return .goodForDay
        case goodForDayDescriptionCimb: return .goodForDay
        case goodUntilCanceledDescription: return .goodUntilCanceled
        case goodUntilCanceledDescriptionCimb: return .goodUntilCanceled
        default: return .unknown
        }
    }
}
