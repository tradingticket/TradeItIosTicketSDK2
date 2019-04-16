class TradeItUiConfigRequest: Codable {
    var apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
}
