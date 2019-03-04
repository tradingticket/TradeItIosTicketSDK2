class TradeItFxOrderInfoInput: TradeItRequest, Codable {
    var orderType: String?
    var orderExpiration: String?
    var orderLegs: [TradeItFxOrderLeg]?
}
