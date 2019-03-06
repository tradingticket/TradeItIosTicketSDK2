class TradeItAuthenticationResult: TradeItResult {
    var accounts: [TradeItBrokerAccount]?
    
    private enum CodingKeys : String, CodingKey {
        case accounts
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var accountsArray = try container.nestedUnkeyedContainer(forKey: .accounts)
        self.accounts = []
        while (!accountsArray.isAtEnd) {
            let account = try accountsArray.decode(TradeItBrokerAccount.self)
            self.accounts?.append(account)
        }
        try super.init(from: decoder)
    }
}
