class TradeItBrokerListResult: TradeItResult {
    var brokerList: [TradeItBroker]?
    var featuredBrokerLabel: String?
    
    private enum CodingKeys : String, CodingKey {
        case brokerList
        case featuredBrokerLabel
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var brokerListArray = try container.nestedUnkeyedContainer(forKey: .brokerList)
        self.brokerList = []
        while (!brokerListArray.isAtEnd) {
            let broker = try brokerListArray.decode(TradeItBroker.self)
            self.brokerList?.append(broker)
        }
        self.featuredBrokerLabel = try container.decode(String.self, forKey: .featuredBrokerLabel)
        try super.init(from: decoder)
    }
}
