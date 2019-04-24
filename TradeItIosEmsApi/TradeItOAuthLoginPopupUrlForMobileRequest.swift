class TradeItOAuthLoginPopupUrlForMobileRequest: TradeItRequest {
    var apiKey: String
    var broker: String
    var interAppAddressCallback: String
    
    init(apiKey: String, broker: String, interAppAddressCallback: String) {
        self.apiKey = apiKey
        self.broker = broker
        self.interAppAddressCallback = interAppAddressCallback
    }
}
