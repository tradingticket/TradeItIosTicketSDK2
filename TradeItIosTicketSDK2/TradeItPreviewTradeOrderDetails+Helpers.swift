@objc public enum TradeItOrderExpiration: Int {
    case goodForDay
    case goodUntilCanceled
    case unknown
}

@objc public enum TradeItOrderPriceType: Int {
    case market
    case limit
    case stopMarket
    case stopLimit
    case unknown
}

@objc public enum TradeItOrderAction: Int {
    case buy
    case sell
    case buyToCover
    case sellShort
    case unknown
}

extension TradeItPreviewTradeOrderDetails {
    func expirationType() -> TradeItOrderExpiration {
        switch self.orderExpiration {
        case "day": return .goodForDay
        case "gtc": return .goodUntilCanceled
        default: return .unknown
        }
    }
}
