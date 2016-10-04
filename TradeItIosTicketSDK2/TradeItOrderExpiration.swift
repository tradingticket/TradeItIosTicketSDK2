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
        case .GoodForDay: return "Buy"
        case .GoodUntilCanceled: return "Sell"
        }
    }

    static func enumFor(type: String) -> TradeItOrderExpiration {
        switch(type) {
        case "Good for Day": return .GoodForDay
        case "Good until Canceled": return .GoodUntilCanceled
        default: return DEFAULT
        }
    }
}
