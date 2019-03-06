class TradeItCryptoPreviewTradeResult: TradeItResult {
    var orderId: Int
    var orderDetails: TradeItCryptoPreviewTradeDetails
    
    init(orderId: Int, orderDetails: TradeItCryptoPreviewTradeDetails) {
        self.orderId = orderId
        self.orderDetails = orderDetails
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        orderId = try values.decode(Int.self, forKey: .orderId)
        orderDetails = try values.decode(TradeItCryptoPreviewTradeDetails.self, forKey: .orderDetails)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys : String, CodingKey {
        case orderId
        case orderDetails
    }
}
