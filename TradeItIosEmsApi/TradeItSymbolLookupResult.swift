class TradeItSymbolLookupResult: TradeItResult {
    var query: String?
    var results: [TradeItSymbolLookupCompany]?
    
    private enum CodingKeys : String, CodingKey {
        case query
        case results
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.query = try container.decode(String.self, forKey: .query)
        var resultsArray = try container.nestedUnkeyedContainer(forKey: .results)
        self.results = []
        while (!resultsArray.isAtEnd) {
            let result = try resultsArray.decode(TradeItSymbolLookupCompany.self)
            self.results?.append(result)
        }
        try super.init(from: decoder)
    }
}
