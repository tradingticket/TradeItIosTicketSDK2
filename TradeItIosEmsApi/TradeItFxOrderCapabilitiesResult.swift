class TradeItFxOrderCapabilitiesResult: TradeItResult {
    var orderCapabilities: TradeItFxOrderCapabilities
    
    init(orderCapabilities: TradeItFxOrderCapabilities) {
        self.orderCapabilities = orderCapabilities
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.orderCapabilities = try container.decode(TradeItFxOrderCapabilities.self, forKey: .orderCapabilities)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys : String, CodingKey {
        case orderCapabilities
    }
}
