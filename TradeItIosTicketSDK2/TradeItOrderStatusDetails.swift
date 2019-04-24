class TradeItOrderStatusDetails: Codable {
    var orderNumber: String?
    var orderExpiration: String?
    var orderType: String?
    var orderStatus: String?
    var orderLegs: [TradeItOrderLeg]?
    var groupOrderId: String?
    var groupOrderType: String?
    var grouOrders: [TradeItOrderStatusDetails]?
}
