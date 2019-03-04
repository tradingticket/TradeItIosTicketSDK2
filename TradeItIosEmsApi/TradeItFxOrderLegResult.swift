class TradeItFxOrderLegResult: Codable {
    var priceType: String?
    var pair: String?
    var action: String?
    var amount: Int = 0
    var rate: Double?
    var orderNumber: String?
    var orderStatus: String?
    var orderStatusMessage: String?
}
