class TradeItPreviewTradeRequest: TradeItAuthenticatedRequest {
    var accountNumber: String
    var orderSymbol: String
    var orderPriceType: String
    var orderAction: String
    var orderQuantity: String
    var orderQuantityType: String
    var orderExpiration: String
    var orderLimitPrice: Double?
    var orderStopPrice: Double?
    var userDisabledMargin: Bool
}
