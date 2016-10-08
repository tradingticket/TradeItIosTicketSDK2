import TradeItIosEmsApi

class TradeItPortfolioBalanceEquityPresenter {

    let balance: TradeItAccountOverview
    
    init(_ tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.balance = tradeItLinkedBrokerAccount.balance
    }

    func getFormattedTotalValue() -> String {
        return NumberFormatter.formatCurrency(self.balance.totalValue)
    }
    
    func getFormattedDayReturn() -> String {
        let dayAbsoluteReturn =  NumberFormatter.formatCurrency(self.balance.dayAbsoluteReturn)
        let dayPercentReturn =  NumberFormatter.formatPercentage(self.balance.dayPercentReturn)
        return dayAbsoluteReturn + " (" + dayPercentReturn + " )"
    }

    func getFormattedAvailableCash() -> String {
        return NumberFormatter.formatCurrency(self.balance.availableCash)
    }

    func getFormattedTotalReturnValue() -> String {
        let totalAbsoluteReturn =  NumberFormatter.formatCurrency(self.balance.totalAbsoluteReturn)
        let totalPercentReturn =  NumberFormatter.formatPercentage(self.balance.totalPercentReturn)
        return totalAbsoluteReturn + " (" + totalPercentReturn + " )"
    }
}
