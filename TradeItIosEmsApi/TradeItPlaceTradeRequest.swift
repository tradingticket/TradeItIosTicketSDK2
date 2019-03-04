class TradeItPlaceTradeRequest: TradeItRequest, Codable {
    var orderId: String?
    var token: String?
    
    init(orderId: String) {
        self.orderId = orderId
    }
}
