class TradeItOAuthAccessTokenResult: TradeItAuthLinkResult {
    var broker: String?
    var brokerLongName: String?
    var activationTime: String?
    
    private enum CodingKeys : String, CodingKey {
        case broker
        case brokerLongName
        case activationTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.broker = try container.decode(String.self, forKey: .broker)
        self.brokerLongName = try container.decode(String.self, forKey: .brokerLongName)
        self.activationTime = try container.decode(String.self, forKey: .activationTime)
        try super.init(from: decoder)
    }
}
