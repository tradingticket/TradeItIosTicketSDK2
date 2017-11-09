@objc public enum TradeItMarginType: Int, RawRepresentable {
    case margin
    case cash
    case null
    
    public var rawValue: RawValue {
        switch self {
        case .margin:
            return "MARGIN"
        case .cash:
            return "CASH"
        default:
            return ""
        }
    }
    
    public var label: String {
        switch self {
        case .margin:
            return "Margin"
        case .cash:
            return "Cash"
        default:
            return ""
        }
    }
    
    public init?(rawValue: RawValue) {
        self.init(value: rawValue)
    }
    
    public init(value: RawValue?) {
        let rawValue = value ?? ""
        switch rawValue {
        case "MARGIN":
            self = .margin
        case "CASH":
            self = .cash
        default:
            self = .null
        }
    }
    
    static func valueFor(label: String) -> TradeItMarginType {
        switch label {
        case "Margin":
            return .margin
        case "Cash":
            return .cash
        default:
            return .null
        }
    }
}

extension TradeItBrokerAccount {

    var marginTypeEnum: TradeItMarginType {
        return TradeItMarginType(value: self.marginType)
    }
}
