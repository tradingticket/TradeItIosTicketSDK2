class TradeItAllOrderStatusResult: TradeItResult {
    var orderStatusDetailsList: [TradeItOrderStatusDetails]?
    
    private enum CodingKeys : String, CodingKey {
        case orderStatusDetailsList
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var orderStatusDetailsListArray = try container.nestedUnkeyedContainer(forKey: .orderStatusDetailsList)
        self.orderStatusDetailsList = []
        while (!orderStatusDetailsListArray.isAtEnd) {
            let orderStatusDetail = try orderStatusDetailsListArray.decode(TradeItOrderStatusDetails.self)
            self.orderStatusDetailsList?.append(orderStatusDetail)
        }
        try super.init(from: decoder)
    }
}
