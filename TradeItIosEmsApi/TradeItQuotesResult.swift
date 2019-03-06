class TradeItQuotesResult: TradeItResult {
    var quotes: [TradeItQuote]?
    
    private enum CodingKeys : String, CodingKey {
        case quotes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var quotesListArray = try container.nestedUnkeyedContainer(forKey: .quotes)
        self.quotes = []
        while (!quotesListArray.isAtEnd) {
            let quote = try quotesListArray.decode(TradeItQuote.self)
            self.quotes?.append(quote)
        }
        try super.init(from: decoder)
    }
}
