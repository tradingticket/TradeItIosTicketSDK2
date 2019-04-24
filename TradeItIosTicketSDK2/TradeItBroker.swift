class TradeItBroker: Codable {
    var shortName: String?
    var longName: String?
    var brokerInstruments: [TradeItBrokerInstrument]?
    var brokerShortName: String?
    var brokerLongName: String?
    var logos: [TradeItBrokerLogo]?
    
    private enum CodingKeys: String, CodingKey {
        case shortName
        case longName
        case brokerInstruments
        case logos
    }
    
    func getBrokerShortName() -> String? {
        return shortName
    }
    
    func getBrokerLongName() -> String? {
        return longName
    }
}
