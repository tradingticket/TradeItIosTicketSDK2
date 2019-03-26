class TradeItPlaceTradeRequest: TradeItRequest, Codable {
    var orderId: Int?
    var token: String?
    
    init(orderId: Int) {
        self.orderId = orderId
    }
}
