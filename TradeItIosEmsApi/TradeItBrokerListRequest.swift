class TradeItBrokerListRequest: TradeItRequest {
    var apiKey: String
    var countryCode: String?
    
    init(apiKey: String, countryCode: String?) {
        self.apiKey = apiKey
        self.countryCode = countryCode
    }
}
