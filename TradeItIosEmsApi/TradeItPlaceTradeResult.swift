public class TradeItPlaceTradeResult: TradeItResult {
    var confirmationMessage: String?
    var orderNumber: String?
    var timestamp: String?
    var broker: String?
    var orderInfo: TradeItPlaceTradeOrderInfo?
    var accountBaseCurrency: String?
    
    private enum CodingKeys : String, CodingKey {
        case confirmationMessage
        case orderNumber
        case timestamp
        case broker
        case orderInfo
        case accountBaseCurrency
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.confirmationMessage = try container.decode(String.self, forKey: .confirmationMessage)
        self.orderNumber = try container.decode(String.self, forKey: .orderNumber)
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.broker = try container.decode(String.self, forKey: .broker)
        self.orderInfo = try container.decodeIfPresent(TradeItPlaceTradeOrderInfo.self, forKey: .orderInfo)
        self.accountBaseCurrency = try container.decode(String.self, forKey: .accountBaseCurrency)
        try super.init(from: decoder)
    }
}
