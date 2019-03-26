class TradeItFxPlaceOrderRequest: TradeItRequest, Codable {
    var token: String?
    var accountNumber: String?
    var fxOrderInfoInput: TradeItFxOrderInfoInput?
}
