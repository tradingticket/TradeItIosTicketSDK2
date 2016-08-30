import TradeItIosEmsApi

class TradeItLinkedAccountPortfolio: NSObject {
    
    var tradeItSession: TradeItSession
    var broker: String = ""
    var accountName: String = ""
    var accountNumber: String = ""
    var balance: TradeItAccountOverview!
    var fxBalance: TradeItFxAccountOverview!
    var positions: [TradeItPortfolioPosition] = []
    var isBalanceError: Bool = false
    var isPositionsError: Bool = false
    
    init(tradeItSession: TradeItSession,
         broker: String,
         accountName: String,
         accountNumber: String,
         balance: TradeItAccountOverview!,
         fxBalance: TradeItFxAccountOverview!,
         positions: [TradeItPortfolioPosition]) {
        self.tradeItSession = tradeItSession
        self.broker = broker
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.balance = balance
        self.fxBalance = fxBalance
        self.positions = positions
    }
    
}
