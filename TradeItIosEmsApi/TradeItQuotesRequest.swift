class TradeItQuotesRequest: TradeItRequest, Codable {
    
    var symbol: String?
    var symbols: String?
    var broker: String?
    var apiKey: String
    var suffixMarket: String?
    
    init(symbol: String, apiKey: String) {
        self.symbol = symbol
        self.apiKey = apiKey
    }
    
    init(symbols: [String], apiKey: String) {
        self.symbols = symbols.joined(separator: ",")
        self.apiKey = apiKey
    }
    
    init(symbol: String, broker: String, apiKey: String) {
        self.symbol = symbol
        self.broker = broker
        self.apiKey = apiKey
    }
    
    init(symbol: String, suffixMarket: String, apiKey: String) {
        self.symbol = symbol
        self.suffixMarket = suffixMarket
        self.apiKey = apiKey
    }
        
}
