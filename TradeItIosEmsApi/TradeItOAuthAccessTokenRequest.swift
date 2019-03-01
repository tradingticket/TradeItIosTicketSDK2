class TradeItOAuthAccessTokenRequest: TradeItRequest {
    var apiKey: String
    var oAuthVerifier: String
    
    init(apiKey: String, oAuthVerifier: String) {
        self.apiKey = apiKey
        self.oAuthVerifier = oAuthVerifier
    }
}
