class TradeItCryptoPreviewTradeResult: TradeItResult {
    var orderId: String
    var orderDetails: TradeItCryptoPreviewTradeDetails
    
    init(orderId: String, orderDetails: TradeItCryptoPreviewTradeDetails) {
        self.orderId = orderId
        self.orderDetails = orderDetails
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        orderId = try values.decode(String.self, forKey: .orderId)
        orderDetails = try values.decode(TradeItCryptoPreviewTradeDetails.self, forKey: .orderDetails)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys : String, CodingKey {
        case orderId
        case orderDetails
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(orderId, forKey: .orderId)
        try container.encode(orderDetails, forKey: .orderDetails)
    }
}
