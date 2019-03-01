class TradeItFxOrderInfoInput: TradeItRequest {
    var orderType: String?
    var orderExpiration: String?
    var orderLegs: [TradeItFxOrderLeg]?
}
