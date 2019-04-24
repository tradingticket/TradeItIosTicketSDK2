class TradeItOAuthLoginPopupUrlForTokenUpdateRequest: TradeItRequest {
    
    var apiKey: String
    var broker: String
    var userId: String
    var userToken: String
    var interAppAddressCallback: String
    
    init(
        apiKey: String,
        broker: String,
        userId: String,
        userToken: String,
        interAppAddressCallback: String
    ) {
        self.apiKey = apiKey
        self.broker = broker
        self.userId = userId
        self.userToken = userToken
        self.interAppAddressCallback = interAppAddressCallback
    }
    
}
