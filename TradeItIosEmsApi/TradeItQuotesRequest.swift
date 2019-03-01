class TradeItQuotesRequest: TradeItRequest {
    
    var symbol: String?
    var broker: String?
    var symbols: String?
    var apiKey: String
    var suffixMarket: String?
    
    init(symbol: String, apiKey: String) {
        self.symbol = symbol
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
