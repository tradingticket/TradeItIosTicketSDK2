public enum TradeItOrderExpiration {
    case goodForDay
    case goodUntilCanceled
    case unknown
}

public enum TradeItOrderPriceType {
    case market
    case limit
    case stopMarket
    case stopLimit
    case unknown
}

public enum TradeItOrderAction {
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
