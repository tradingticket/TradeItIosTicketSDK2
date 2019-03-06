public class TradeItPreviewTradeResult: TradeItResult {
    var warningsList: [String]?
    var ackWarningsList: [String]?
    var orderId: Int = -1
    var orderDetails: TradeItPreviewTradeOrderDetails?
    var accountBaseCurrency: String?
    
    private enum CodingKeys : String, CodingKey {
        case warningsList
        case ackWarningsList
        case orderId
        case orderDetails
        case accountBaseCurrency
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var warningsListArray = try container.nestedUnkeyedContainer(forKey: .warningsList)
        self.warningsList = []
        while (!warningsListArray.isAtEnd) {
            let warning = try warningsListArray.decode(String.self)
            self.warningsList?.append(warning)
        }
        var ackWarningsListArray = try container.nestedUnkeyedContainer(forKey: .ackWarningsList)
        self.ackWarningsList = []
        while (!ackWarningsListArray.isAtEnd) {
            let ackWarning = try ackWarningsListArray.decode(String.self)
            self.ackWarningsList?.append(ackWarning)
        }
        self.orderId = try container.decode(Int.self, forKey: .orderId)
        self.orderDetails = try container.decode(TradeItPreviewTradeOrderDetails.self, forKey: .orderDetails)
        self.accountBaseCurrency = try container.decode(String.self, forKey: .accountBaseCurrency)
        try super.init(from: decoder)
    }
}
