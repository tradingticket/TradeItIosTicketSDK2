class TradeItSDKPortfolio: NSObject {
    
    var tradeItSession: TradeItSession
    var broker: String = ""
    var accountName: String = ""
    var accountNumber: String = ""
    var balance: TradeItAccountOverviewResult!
    var isBalanceError: Bool = false
    
    init(tradeItSession: TradeItSession, broker: String, accountName: String, accountNumber: String, balance: TradeItAccountOverviewResult!) {
        self.tradeItSession = tradeItSession
        self.broker = broker
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.balance = balance
    }
    
}
