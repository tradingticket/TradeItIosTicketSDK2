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
    var tradeItBalanceService: TradeItBalanceService
    var tradeItPositionService: TradeItPositionService
    var tradeService: TradeItTradeService
    var isEnabled = true

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
        self.tradeItPositionService = TradeItPositionService(session: self.linkedBroker.session)
        self.tradeService = TradeItTradeService(session: self.linkedBroker.session)
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

    func getPositions(onFinished onFinished: ()-> Void) {
        let request = TradeItGetPositionsRequest(accountNumber: self.accountNumber)
        self.tradeItPositionService.getAccountPositions(request, withCompletionBlock: {(tradeItResult: TradeItResult!) -> Void in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                //TODO
                print("Error \(tradeItErrorResult)")
                self.isPositionsError = true
            } else if let tradeItGetPositionsResult = tradeItResult as? TradeItGetPositionsResult {
                var positionsPortfolio:[TradeItPortfolioPosition] = []

                let positions = tradeItGetPositionsResult.positions as! [TradeItPosition]
                for position in positions {
                    let positionPortfolio = TradeItPortfolioPosition(linkedBrokerAccount: self, position: position)
                    positionsPortfolio.append(positionPortfolio)
                }

                let fxPositions = tradeItGetPositionsResult.fxPositions as! [TradeItFxPosition]
                for fxPosition in fxPositions {
                    let positionPortfolio = TradeItPortfolioPosition(linkedBrokerAccount: self, fxPosition: fxPosition)
                    positionsPortfolio.append(positionPortfolio)
                }

                self.positions = positionsPortfolio
            }
            onFinished()
        })
    }

    func getFormattedAccountName() -> String {
        var formattedAccountNumber = self.accountNumber
        var formattedAccountName = self.accountName
        var separator = " "
        if formattedAccountNumber.characters.count > 4 {
            let startIndex = formattedAccountNumber.endIndex.advancedBy(-4)
            formattedAccountNumber = String(formattedAccountNumber.characters.suffixFrom(startIndex))
            separator = "**"
        }

        if formattedAccountName.characters.count > 10 {
            formattedAccountName = String(formattedAccountName.characters.prefix(10))
            separator = "**"
        }

        return "\(formattedAccountName)\(separator)\(formattedAccountNumber)"
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

    func getFormattedTotalValueWithPercentage() -> String{
        if let balance = self.balance {
            var formattedTotalValue = NumberFormatter.formatCurrency(balance.totalValue)
            if let totalPercentReturn = balance.totalPercentReturn {
                formattedTotalValue += " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
            }
            return formattedTotalValue
        }

        else if let fxBalance = self.fxBalance {
            var formattedTotalValue = NumberFormatter.formatCurrency(fxBalance.totalValueBaseCurrency)
            if fxBalance.unrealizedProfitAndLossBaseCurrency != nil && fxBalance.unrealizedProfitAndLossBaseCurrency.floatValue != 0 {
                let totalReturn = fxBalance.unrealizedProfitAndLossBaseCurrency.floatValue
                let totalPercentReturn = totalReturn / (fxBalance.totalValueBaseCurrency.floatValue - abs(totalReturn))
                    formattedTotalValue += " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
            }

            return formattedTotalValue
        }

        else {
            return "N/A"
        }
    }

}
