class TradeItUpdateLinkRequest: TradeItRequest {

    var id: String
    var password: String
    var broker: String
    var apiKey: String
    var userId: String
    
    init(userId: String, authInfo: TradeItAuthenticationInfo, apiKey: String) {
        self.userId = userId
        self.id = authInfo.id
        self.password = authInfo.password
        self.broker = authInfo.broker
        self.apiKey = apiKey
    }
}
