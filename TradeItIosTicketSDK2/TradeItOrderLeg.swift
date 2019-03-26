class TradeItOrderLeg: Codable {
    var symbol: String?
    var orderedQuantity: Double?
    var filledQuantity: Double?
    var action: String?
    var priceInfo: TradeItPriceInfo?
    var fills: [TradeItOrderFill]?
    var groupOrder: [TradeItOrderStatusDetails]?
    var groupOrderId: String?
}
