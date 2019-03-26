class TradeItCryptoPreviewTradeRequest: TradeItAuthenticatedRequest {
    var accountNumber: String = ""
    var orderPair: String = ""
    var orderPriceType: String = ""
    var orderAction: String = ""
    var orderQuantity: Double = 0.0
    var orderExpiration: String = ""
    var orderQuantityType: String = ""
    var orderLimitPrice: Double? = nil
    var orderStopPrice: Double? = nil
    
    private enum CodingKeys: String, CodingKey {
        case accountNumber
        case orderPair
        case orderPriceType
        case orderAction
        case orderQuantity
        case orderQuantityType
        case orderExpiration
        case orderLimitPrice
        case orderStopPrice
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encode(orderPair, forKey: .orderPair)
        try container.encode(orderPriceType, forKey: .orderPriceType)
        try container.encode(orderAction, forKey: .orderAction)
        try container.encode(orderQuantity, forKey: .orderQuantity)
        try container.encode(orderQuantityType, forKey: .orderQuantityType)
        try container.encode(orderExpiration, forKey: .orderExpiration)
        try container.encodeIfPresent(orderLimitPrice, forKey: .orderLimitPrice)
        try container.encodeIfPresent(orderStopPrice, forKey: .orderStopPrice)
        try super.encode(to: encoder)
    }
}
