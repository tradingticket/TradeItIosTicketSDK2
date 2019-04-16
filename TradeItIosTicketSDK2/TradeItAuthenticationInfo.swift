class TradeItAuthenticationInfo: Codable {
    var id: String
    var password: String
    var broker: String
    
    init() {
        self.id = ""
        self.password = ""
        self.broker = ""
    }
    
    init(withId id: String, andPassword password: String, andBroker broker: String) {
        self.id = id
        self.password = password
        self.broker = broker
    }
}
