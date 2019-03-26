class TradeItAuthLinkRequest: TradeItRequest {
    
    var id: String
    var password: String
    var broker: String
    var apiKey: String
    
    init(authInfo: TradeItAuthenticationInfo, apiKey: String) {
        self.id = authInfo.id
        self.password = authInfo.password
        self.broker = authInfo.broker
        self.apiKey = apiKey
    }
}
