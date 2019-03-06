class TradeItUiConfigResult: TradeItResult {
    var brokers: [TradeItUiBrokerConfig] = []
    
    private enum CodingKeys : String, CodingKey {
        case brokers
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var brokersArray = try container.nestedUnkeyedContainer(forKey: .brokers)
        while (!brokersArray.isAtEnd) {
            let brokerConfig = try brokersArray.decode(TradeItUiBrokerConfig.self)
            self.brokers.append(brokerConfig)
        }
        try super.init(from: decoder)
    }
}
