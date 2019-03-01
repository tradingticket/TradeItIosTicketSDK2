class TradeItAccountOverviewRequest: TradeItRequest {
    
    var accountnumber: String
    var token: String?
    
    init(accountNumber: String) {
        self.accountNumber = accountNumber
    }
}
