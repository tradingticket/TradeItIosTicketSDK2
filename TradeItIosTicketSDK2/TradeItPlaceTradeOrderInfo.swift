class TradeItPlaceTradeOrderInfo: Codable {
    var symbol: String?
    var action: String?
    var quantity: Double?
    var expiration: Double?
    var price: TradeItPlaceTradeOrderInfoPrice?
}
