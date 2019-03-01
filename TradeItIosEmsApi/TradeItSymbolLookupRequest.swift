class TradeItSymbolLookupRequest: TradeItRequest {
    var query: String
    var token: String?
    
    init(query: String) {
        self.query = query
    }
}
