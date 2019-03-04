class TradeItAuthenticationRequest: TradeItRequest, Codable {
    
    var userToken: String
    var userId: String
    var apiKey: String
    var advertisingId: String?
    
    init(userToken: String, userId: String, apiKey: String, advertisingId: String?) {
        self.userToken = userToken
        self.userId = userId
        self.apiKey = apiKey
        self.advertisingId = advertisingId
    }
}
