@objc public class TradeItTransactionsHistoryResult: TradeItResult {
    var numberOfDaysHistory: Int = 0
    var transactionHistoryDetailsList: [TradeItTransaction]?
    
    private enum CodingKeys : String, CodingKey {
        case numberOfDaysHistory
        case transactionHistoryDetailsList
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.numberOfDaysHistory = try container.decode(Int.self, forKey: .numberOfDaysHistory)
        var transactionHistoryDetailsListArray = try container.nestedUnkeyedContainer(forKey: .transactionHistoryDetailsList)
        self.transactionHistoryDetailsList = []
        while (!transactionHistoryDetailsListArray.isAtEnd) {
            let transactionHistoryDetail = try transactionHistoryDetailsListArray.decode(TradeItTransaction.self)
            self.transactionHistoryDetailsList?.append(transactionHistoryDetail)
        }
        try super.init(from: decoder)
    }
}
