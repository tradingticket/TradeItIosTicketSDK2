class TradeItCancelOrderRequest: TradeItRequest, Codable {
    var token: String?
    var accountNumber: String?
    var orderNumber: String?
}
