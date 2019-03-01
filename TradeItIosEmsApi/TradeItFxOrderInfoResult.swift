class TradeItFxOrderInfoResult: Codable {
    var orderType: String?
    var orderExpiration: String?
    var orderLegs: [TradeItFxOrderLegResults]
}
