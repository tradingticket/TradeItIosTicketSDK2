import TradeItIosEmsApi

class TradeItPortfolioBalanceFXPresenter {

    let fxBalance: TradeItFxAccountOverview
    let tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount
    
    init(_ tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.tradeItLinkedBrokerAccount = tradeItLinkedBrokerAccount
        self.fxBalance = tradeItLinkedBrokerAccount.fxBalance
    }
    
    func getFormattedTotalValue() -> String {
        return formatCurrency(self.fxBalance.totalValueUSD)
    }
    
    func getUnrealizedProfitAndLoss() -> String {
        return formatCurrency(self.tradeItLinkedBrokerAccount.fxBalance.unrealizedProfitAndLossBaseCurrency)
    }
    
    func getRealizedProfitAndLoss() -> String {
        return formatCurrency(self.tradeItLinkedBrokerAccount.fxBalance.realizedProfitAndLossBaseCurrency)

    }
    
    func getMarginBalance() -> String {
        return formatCurrency(self.tradeItLinkedBrokerAccount.fxBalance.marginBalanceBaseCurrency)
    }
    
    private func formatCurrency(currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
    }
}
