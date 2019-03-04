class TradeItAccountOverviewRequest: TradeItRequest, Codable {
    
    var accountNumber: String
    var token: String?
    
    init(accountNumber: String) {
        self.accountNumber = accountNumber
    }
}
