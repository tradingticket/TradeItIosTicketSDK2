public enum TradeItOrderExpiration {
    case GoodForDay
    case GoodUntilCanceled
    case Unknown
}

public enum TradeItOrderPriceType {
    case Market
    case Limit
    case StopMarket
    case StopLimit
    case Unknown
}

public enum TradeItOrderAction {
    case Buy
    case Sell
    case BuyToCover
    case SellShort
    case Unknown
}

extension TradeItPreviewTradeOrderDetails {
    func expirationType() -> TradeItOrderExpiration {
        switch self.orderExpiration {
        case "day": return .GoodForDay
        case "gtc": return .GoodUntilCanceled
        default: return .Unknown
        }
    }
}
