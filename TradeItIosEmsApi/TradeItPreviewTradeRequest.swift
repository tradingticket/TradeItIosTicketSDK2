class TradeItPreviewTradeRequest: TradeItAuthenticatedRequest {
    var accountNumber: String = ""
    var orderSymbol: String = ""
    var orderPriceType: String = ""
    var orderAction: String = ""
    var orderQuantity: Double = 0.0
    var orderQuantityType: String = ""
    var orderExpiration: String = ""
    var orderLimitPrice: Double?
    var orderStopPrice: Double?
    var userDisabledMargin: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case accountNumber
        case orderSymbol
        case orderPriceType
        case orderAction
        case orderQuantity
        case orderQuantityType
        case orderExpiration
        case orderLimitPrice
        case orderStopPrice
        case userDisabledMargin
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encode(orderSymbol, forKey: .orderSymbol)
        try container.encode(orderPriceType, forKey: .orderPriceType)
        try container.encode(orderAction, forKey: .orderAction)
        try container.encode(orderQuantity, forKey: .orderQuantity)
        try container.encode(orderQuantityType, forKey: .orderQuantityType)
        try container.encode(orderExpiration, forKey: .orderExpiration)
        try container.encodeIfPresent(orderLimitPrice, forKey: .orderLimitPrice)
        try container.encodeIfPresent(orderStopPrice, forKey: .orderStopPrice)
        try container.encode(userDisabledMargin, forKey: .userDisabledMargin)
        try super.encode(to: encoder)
    }
}
