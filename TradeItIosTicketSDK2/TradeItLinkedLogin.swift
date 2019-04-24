class TradeItLinkedLogin: Codable {
    var label: String
    var broker: String
    var brokerLongName: String
    var userId: String
    var keychainId: String
    
    init(
        label: String,
        broker: String,
        brokerLongName: String,
        userId: String,
        keychainId: String
    ) {
        self.label = label
        self.broker = broker
        self.brokerLongName = brokerLongName
        self.userId = userId
        self.keychainId = keychainId
    }
}
