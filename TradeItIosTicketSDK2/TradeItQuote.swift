@objc public class TradeItQuote: NSObject,  Codable {
    public var symbol: String?
    public var companyName: String?
    public var askPrice: Double?
    public var bidPrice: Double?
    public var lastPrice: Double?
    public var change: Double?
    public var pctChange: Double?
    public var low: Double?
    public var high: Double?
    public var volume: Double?
    public var dateTime: String?
}
