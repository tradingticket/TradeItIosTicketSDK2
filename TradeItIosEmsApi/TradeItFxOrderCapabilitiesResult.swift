class TradeItFxOrderCapabilitiesResult: TradeItResult {
    var orderCapabilities: TradeItFxOrderCapabilities
    
    init(orderCapabilities: TradeItFxOrderCapabilities) {
        self.orderCapabilities = orderCapabilities
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        orderCapabilities = try values.decode(TradeItFxOrderCapabilities.self, forKey: .orderCapabilities)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys : String, CodingKey {
        case orderCapabilities
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(orderCapabilities, forKey: .orderCapabilities)
    }
}
