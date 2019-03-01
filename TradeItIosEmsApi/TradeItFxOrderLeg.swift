class TradeItFxOrderLeg: TradeItRequest {
    var priceType: String
    var pair: String
    var action: String
    var amount: Double
    var rate: Double?
    var leverage: Double?
}
