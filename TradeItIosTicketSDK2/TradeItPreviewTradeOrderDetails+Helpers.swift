public typealias RawValue = String

@objc public enum TradeItOrderExpiration: Int, RawRepresentable {
    case goodForDay
    case goodUntilCanceled
    case fillOrKill
    case unknown
    
    public var rawValue: RawValue {
        switch self {
        case .goodForDay: return "day"
        case .goodUntilCanceled: return "gtc"
        case .fillOrKill: return "fok"
        default: return "unknown"
        }
    }
    
    public init?(rawValue: RawValue) {
        self.init(value: rawValue)
    }
    
    public init(value: RawValue?) {
        let rawValue = value ?? "unknown"
        switch rawValue {
        case "day": self = .goodForDay
        case "gtc": self = .goodUntilCanceled
        case "fok": self = .fillOrKill
        default: self = .unknown
        }
    }

}

@objc public enum TradeItOrderPriceType: Int, RawRepresentable {
    case market
    case limit
    case stopMarket
    case stopLimit
    case unknown
    
    public var rawValue: RawValue {
        switch self {
        case .market:
            return "market"
        case .limit:
            return "limit"
        case .stopMarket:
            return "stopMarket"
        case .stopLimit:
            return "stopLimit"
        default:
            return "unknown"
        }
    }
    
    public init?(rawValue: RawValue) {
        self.init(value: rawValue)
    }
    
    public init(value: RawValue?) {
        let rawValue = value ?? "unknown"
        switch rawValue {
        case "market":
            self = .market
        case "limit":
            self = .limit
        case "stopMarket":
            self = .stopMarket
        case "stopLimit":
            self = .stopLimit
        default:
            self = .unknown
        }
    }

}

@objc public enum TradeItOrderAction: Int, RawRepresentable {
    case buy
    case sell
    case buyToCover
    case sellShort
    case unknown
    
    public var rawValue: RawValue {
        switch self {
        case .buy:
            return "buy"
        case .sell:
            return "sell"
        case .buyToCover:
            return "buyToCover"
        case .sellShort:
            return "sellShort"
        default:
            return "unknown"
        }
    }
    
    public init?(rawValue: RawValue) {
        self.init(value: rawValue)
    }
    
    public init(value: RawValue?) {
        let rawValue = value ?? "unknown"
        switch rawValue {
        case "buy":
            self = .buy
        case "sell":
            self = .sell
        case "buyToCover":
            self = .buyToCover
        case "sellShort":
            self = .sellShort
        default:
            self = .unknown
        }
    }
}
