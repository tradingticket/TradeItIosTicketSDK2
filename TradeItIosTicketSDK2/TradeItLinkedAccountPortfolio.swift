import TradeItIosEmsApi

class TradeItAccountPortfolio: NSObject {
    var accountName: String = ""
    var accountNumber: String = ""
    var balance: TradeItAccountOverview!
    var fxBalance: TradeItFxAccountOverview!
    var positions: [TradeItPortfolioPosition] = []
    var isBalanceError: Bool = false
    var isPositionsError: Bool = false


    init(accountName: String,
         accountNumber: String,
         balance: TradeItAccountOverview!,
         fxBalance: TradeItFxAccountOverview!,
         positions: [TradeItPortfolioPosition]) {
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.balance = balance
        self.fxBalance = fxBalance
        self.positions = positions
    }
}