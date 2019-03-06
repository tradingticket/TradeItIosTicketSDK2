@objc public class TradeItInstrumentOrderCapabilities: NSObject, Codable {
    var instrument: String
    var tradeItSymbol: String?
    var precision: Int?
    var actions: [TradeItInstrumentCapability]
    var expirationTypes: [TradeItInstrumentCapability]
    var priceTypes: [TradeItInstrumentCapability]
}
