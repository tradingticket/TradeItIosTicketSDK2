@objc public class TradeItBroker: NSObject, Codable {
    var shortName: String?
    var longName: String?
    var brokerInstruments: [TradeItBrokerInstrument]?
    var brokerShortName: String? {
        return shortName
    }
    var brokerLongName: String? {
        return longName
    }
    var logos: [TradeItBrokerLogo]?
    
    private enum CodingKeys: String, CodingKey {
        case shortName
        case longName
        case brokerInstruments
        case logos
    }
}
