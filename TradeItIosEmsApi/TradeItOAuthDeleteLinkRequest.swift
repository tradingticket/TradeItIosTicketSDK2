class TradeItOAuthDeleteLinkRequest: TradeItRequest {
    var apiKey: String
    var userId: String
    var userToken: String?
    
    init(apiKey: String, userId: String, userToken: String?) {
        self.apiKey = apiKey
        self.userId = userId
        self.userToken = userToken
    }
}
