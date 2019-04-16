class TradeItSymbolLookupRequest: TradeItRequest, Codable {
    var query: String
    var token: String?
    
    init(query: String) {
        self.query = query
    }
}
