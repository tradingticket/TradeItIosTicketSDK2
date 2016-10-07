enum TradeItOrderExpiration {
    case GoodForDay
    case GoodUntilCanceled
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
        }
    }

    static func enumFor(type: String) -> TradeItOrderExpiration {
        switch(type) {
        case "Good for day": return .GoodForDay
        case "Good until canceled": return .GoodUntilCanceled
        default: return DEFAULT
        }
    }
}
