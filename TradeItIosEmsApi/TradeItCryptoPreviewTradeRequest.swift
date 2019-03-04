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
}
