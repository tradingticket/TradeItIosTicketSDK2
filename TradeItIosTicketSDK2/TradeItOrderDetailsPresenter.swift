class TradeItOrderDetailsPresenter {
    private let orderAction: String?
    private let orderExpiration: String?
    private let orderCapabilities: TradeItInstrumentOrderCapabilities?

    init(
        orderAction: String?,
        orderExpiration: String?,
        orderCapabilities: TradeItInstrumentOrderCapabilities?
    ) {
        self.orderAction = orderAction
        self.orderExpiration = orderExpiration
        self.orderCapabilities = orderCapabilities
    }    
    
    func getOrderExpirationLabel() -> String {
        return self.orderCapabilities?.labelFor(field: .expirationTypes, value: self.orderExpiration) ?? "Unknown"
    }
    
    func getOrderActionLabel() -> String {
        return self.orderCapabilities?.labelFor(field: .actions, value: self.orderAction) ?? "Unknown"
    }
}

class TradeItOrderPriceTypePresenter {
    static let DEFAULT: TradeItOrderPriceType            = .market
    static let TYPES: [TradeItOrderPriceType]            = [.market, .limit, .stopMarket, .stopLimit]
    static let LIMIT_TYPES: [TradeItOrderPriceType]      = [.limit, .stopLimit]
    static let STOP_TYPES: [TradeItOrderPriceType]       = [.stopLimit, .stopMarket]
    static let EXPIRATION_TYPES: [TradeItOrderPriceType] = [.limit, .stopMarket, .stopLimit]
}

public class TradeItOrderActionPresenter {
    public static let DEFAULT: TradeItOrderAction = .buy
    static let ACTIONS: [TradeItOrderAction] = [.buy, .sell, .buyToCover, .sellShort]
    static let SELL_ACTIONS: [TradeItOrderAction] = [.sell, .sellShort]
}

class TradeItOrderExpirationPresenter {
    static let DEFAULT: TradeItOrderExpiration = .goodForDay
    static let ACTIONS: [TradeItOrderExpiration] = [.goodForDay, .goodUntilCanceled]
}
