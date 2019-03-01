class TradeItBrokerInstrument: Codable {
    var instrument: String
    var isFeatured: Bool
    var supportsAccountOverview: Bool
    var supportsFxRates: Bool
    var supportsOrderCanceling: Bool
    var supportsOrderStatus: Bool
    var supportsPositions: Bool
    var supportsTrading: Bool
    var supportsTransactionHistory: Bool
}
