class TradeItAccountOverviewRequest: Codable { // TODO: make struct
    var accountNumber: String?
    var token: String?

    init(accountNumber: String) {
        self.accountNumber = accountNumber
    }
}
