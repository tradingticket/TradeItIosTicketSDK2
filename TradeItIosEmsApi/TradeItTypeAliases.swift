@objc public enum TradeitEmsEnvironments : Int {
    case tradeItEmsProductionEnv
    case tradeItEmsTestEnv
    case tradeItEmsLocalEnv
}

@objc public enum TradeItEmsApiVersion : Int {
    case _1
    case _2
}

typealias TradeItRequestCompletionBlock = (TradeItResult?) -> Void
