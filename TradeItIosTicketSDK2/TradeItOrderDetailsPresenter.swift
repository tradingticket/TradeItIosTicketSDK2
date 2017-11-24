class TradeItOrderDetailsPresenter {
    private var orderDetails: TradeItPreviewTradeOrderDetails
    private var orderCapabilities: TradeItInstrumentOrderCapabilities?

    var userDisabledMargin: Bool {
        return self.orderDetails.userDisabledMargin
    }

    init(orderDetails: TradeItPreviewTradeOrderDetails, orderCapabilities: TradeItInstrumentOrderCapabilities?) {
        self.orderDetails = orderDetails
        self.orderCapabilities = orderCapabilities
    }    
    
    func getOrderExpirationLabel() -> String {
        return self.orderCapabilities?.labelFor(field: .expirationTypes, value: self.orderDetails.orderExpiration) ?? "Unknown"
    }
    
    func getOrderActionLabel() -> String {
        return self.orderCapabilities?.labelFor(field: .actions, value: self.orderDetails.orderAction) ?? "Unknown"
    }
}

class TradeItOrderPriceTypePresenter {
    static let DEFAULT: TradeItOrderPriceType            = .market
    static let TYPES: [TradeItOrderPriceType]            = [.market, .limit, .stopMarket, .stopLimit]
    static let LIMIT_TYPES: [TradeItOrderPriceType]      = [.limit, .stopLimit]
    static let STOP_TYPES: [TradeItOrderPriceType]       = [.stopLimit, .stopMarket]
    static let EXPIRATION_TYPES: [TradeItOrderPriceType] = [.limit, .stopMarket, .stopLimit]
}

class TradeItOrderActionPresenter {
    static let DEFAULT: TradeItOrderAction = .buy
    static let ACTIONS: [TradeItOrderAction] = [.buy, .sell, .buyToCover, .sellShort]
    static let SELL_ACTIONS: [TradeItOrderAction] = [.sell, .sellShort]
}

class TradeItOrderExpirationPresenter {
    static let DEFAULT: TradeItOrderExpiration = .goodForDay
    static let ACTIONS: [TradeItOrderExpiration] = [.goodForDay, .goodUntilCanceled]
}
