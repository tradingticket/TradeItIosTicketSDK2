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
    unowned var linkedBroker: TradeItLinkedBroker
    var tradeItBalanceService: TradeItBalanceService!
    
    init(linkedBroker: TradeItLinkedBroker,
        brokerName: String,
         accountName: String,
         accountNumber: String,
         balance: TradeItAccountOverview!,
         fxBalance: TradeItFxAccountOverview!,
         positions: [TradeItPortfolioPosition]) {
        self.linkedBroker = linkedBroker
        self.brokerName = brokerName
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.balance = balance
        self.fxBalance = fxBalance
        self.positions = positions
        self.tradeItBalanceService = TradeItBalanceService(session: self.linkedBroker.session)
    }

    func getAccountOverview(onFinished onFinished: ()-> Void) {
        let request = TradeItAccountOverviewRequest(accountNumber: self.accountNumber)
        self.tradeItBalanceService.getAccountOverview(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                // TODO: reject
                print("Error \(tradeItErrorResult)")
                self.isBalanceError = true
            } else if let tradeItAccountOverviewResult = tradeItResult as? TradeItAccountOverviewResult {
                self.isBalanceError = false
                self.balance = tradeItAccountOverviewResult.accountOverview
                self.fxBalance = tradeItAccountOverviewResult.fxAccountOverview
            }

            onFinished()
        })
    }
}