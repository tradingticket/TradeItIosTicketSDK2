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
    
    //MARK: formatting methods
    
    func getFormattedAccountName() -> String {
        var formattedAccountNumber = self.accountNumber
        var formattedAccountName = self.accountName
        
        if formattedAccountNumber.characters.count > 4 {
            let startIndex = formattedAccountNumber.endIndex.advancedBy(-4)
            formattedAccountNumber = String(formattedAccountNumber.characters.suffixFrom(startIndex))
        }
        
        if formattedAccountName.characters.count > 10 {
            formattedAccountName = String(formattedAccountName.characters.prefix(10))
        }
        
        return "\(formattedAccountName)**\(formattedAccountNumber)"
    }
    
    func getFormattedBuyingPower() -> String{
        if let balance = self.balance {
            return NumberFormatter.formatCurrency(balance.buyingPower)
        }
            
        else if let fxBalance = self.fxBalance {
            return NumberFormatter.formatCurrency(fxBalance.buyingPowerBaseCurrency)
        }
            
        else {
            return "N/A"
        }
    }
    
    func getFormattedTotalValue() -> String{
        if let balance = self.balance {
            return NumberFormatter.formatCurrency(balance.totalValue)
        }
            
        else if let fxBalance = self.fxBalance {
            return NumberFormatter.formatCurrency(fxBalance.totalValueBaseCurrency)
        }
            
        else {
            return "N/A"
        }
    }

}