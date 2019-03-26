class TradeItFxOrderLeg: TradeItRequest, Codable {
    var priceType: String = ""
    var pair: String = ""
    var action: String = ""
    var amount: Double = 0.0
    var rate: Double? = nil
    var leverage: Double? = nil
}
