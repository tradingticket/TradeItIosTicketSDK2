class TradeItBrokerAccount: Codable {
    var accountBaseCurrency: String
    var accountNumber: String
    var accountIndex: String
    var name: String
    var tradable: Bool
    var userCanDisableMargin: Bool
    var orderCapabilities: [TradeItInstrumentOrderCapabilities]
    
    init(accountBaseCurrency: String, accountNumber: String, name: String, tradable: Bool) {
        self.accountBaseCurrency = accountBaseCurrency
        self.accountNumber = accountNumber
        self.name = name
        self.tradable = tradable
        self.userCanDisableMargin = false
        self.orderCapabilities = []
        self.accountIndex = ""
    }
}
