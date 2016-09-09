import TradeItIosEmsApi

class TradeItLinkedBrokerAccount: NSObject {
    var brokerName = ""
    var accountName = ""
    var accountNumber = ""
    var balance: TradeItAccountOverview!
    var fxBalance: TradeItFxAccountOverview!
    var positions: [TradeItPortfolioPosition] = []
    var isBalanceError: Bool = false
    var isPositionsError: Bool = false

    init(brokerName: String,
         accountName: String,
         accountNumber: String,
         balance: TradeItAccountOverview!,
         fxBalance: TradeItFxAccountOverview!,
         positions: [TradeItPortfolioPosition]) {
        self.brokerName = brokerName
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.balance = balance
        self.fxBalance = fxBalance
        self.positions = positions
    }

    func getAccountsOverView(onFinishedRefreshingBalances: ()-> Void) -> Void {
//        let request = TradeItAccountOverviewRequest(accountNumber: self.accountNumber)
//        self.tradeItBalanceService.session = linkedBrokerAccount.tradeItSession
//        self.tradeItBalanceService.getAccountOverview(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
//            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
//                // TODO: reject
//                print("Error \(tradeItErrorResult)")
//                self.isBalanceError = true
//            } else if let tradeItAccountOverviewResult = tradeItResult as? TradeItAccountOverviewResult {
//                self.isBalanceError = false
//                self.balance = tradeItAccountOverviewResult.accountOverview
//                self.fxBalance = tradeItAccountOverviewResult.fxAccountOverview
//            }
//
//            onFinishedGettingAccountOverview()
//        })
    }
}