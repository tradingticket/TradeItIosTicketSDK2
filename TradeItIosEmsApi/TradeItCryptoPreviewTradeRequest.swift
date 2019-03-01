class TradeItCryptoPreviewTradeRequest: TradeItAuthenticatedRequest {
    var accountNumber: String
    var orderPair: String
    var orderPriceType: String
    var orderAction: String
    var orderQuantity: Double
    var orderExpiration: String
    var orderQuantityType: String
    var orderLimitPrice: Double?
    var orderStopPrice: Double?
}
