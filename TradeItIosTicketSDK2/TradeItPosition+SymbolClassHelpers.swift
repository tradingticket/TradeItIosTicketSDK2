enum TradeItPositionInstrumentType: String {
    case OPTION
    case EQUITY_OR_ETF
    case BUY_WRITES
    case SPREADS
    case COMBO
    case MULTILEG
    case MUTUAL_FUNDS
    case FIXED_INCOME
    case CASH
    case UNKNOWN
    case FX
    case FUTURE
}

extension TradeItPosition {
    func instrumentType() -> TradeItPositionInstrumentType? {
        if let symbolClass = self.symbolClass {
            return TradeItPositionInstrumentType(rawValue: symbolClass)
        } else {
            return .UNKNOWN
        }
    }
}

extension TradeItFxPosition {
    func instrumentType() -> TradeItPositionInstrumentType? {
        return .FX
    }
}
