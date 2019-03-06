public class TradeItFxPlaceOrderResult: TradeItResult {

    var confirmationMessage: String?
    var timestamp: String?
    var broker: String?
    var accountBaseCurrency: String?
    var orderInfoOutput: TradeItFxOrderInfoResult?
    
    private enum CodingKeys : String, CodingKey {
        case confirmationMessage
        case timestamp
        case broker
        case accountBaseCurrency
        case orderInfoOutput
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.confirmationMessage = try container.decode(String.self, forKey: .confirmationMessage)
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.broker = try container.decode(String.self, forKey: .broker)
        self.accountBaseCurrency = try container.decode(String.self, forKey: .accountBaseCurrency)
        self.orderInfoOutput = try container.decode(TradeItFxOrderInfoResult.self, forKey: .orderInfoOutput)
        try super.init(from: decoder)
    }
}
