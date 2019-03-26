class TradeItGetPositionsRequest: TradeItRequest, Codable {
    var accountNumber: String?
    var page: Int?
    var token: String?
    
    init(accountNumber: String) {
        self.accountNumber = accountNumber
    }
}
