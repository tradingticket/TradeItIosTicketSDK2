class TradeItCryptoPreviewTradeDetails: Codable {
    var orderPair: String
    var orderAction: String
    var orderPriceType: String
    var orderExpiration: String
    var orderQuantity: Double
    var orderQuantityType: String
    var orderCommissionLabel: String
    var orderLimitPrice: Double?
    var orderStopPrice: Double?
    var estimatedOrderValue: Double?
    var estimatedOrderCommission: Double?
    var estimatedTotalValue: Double?
    var warnings: [TradeItPreviewMessage]?
}














