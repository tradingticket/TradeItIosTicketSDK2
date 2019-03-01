class TradeItGetPositionsRequest: TradeItRequest {
    var accountNumber: String?
    var page: Int?
    var token
    
    init(accountNumber: String) {
        self.accountNumber = accountnumber
    }
}
