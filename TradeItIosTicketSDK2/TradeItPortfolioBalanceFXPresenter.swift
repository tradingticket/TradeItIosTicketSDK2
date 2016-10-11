import TradeItIosEmsApi

class TradeItPortfolioBalanceFXPresenter  {

    var fxBalance: TradeItFxAccountOverview = TradeItFxAccountOverview()
    
    init(_ tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount) {
        if let fxBalance = tradeItLinkedBrokerAccount.fxBalance {
            self.fxBalance = fxBalance
        }
    }
    
    func getFormattedTotalValue() -> String {
        guard let totalValueUSD = self.fxBalance.totalValueUSD
            else {return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        return formatCurrency(totalValueUSD)
    }
    
    func getUnrealizedProfitAndLoss() -> String {
        guard let unrealizedProfitAndLossBaseCurrency = self.fxBalance.unrealizedProfitAndLossBaseCurrency
            else {return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        return formatCurrency(unrealizedProfitAndLossBaseCurrency)
    }
    
    func getRealizedProfitAndLoss() -> String {
        guard let realizedProfitAndLossBaseCurrency = self.fxBalance.realizedProfitAndLossBaseCurrency
            else {return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        return formatCurrency(realizedProfitAndLossBaseCurrency)

    }
    
    func getMarginBalance() -> String {
        guard let marginBalanceBaseCurrency = self.fxBalance.marginBalanceBaseCurrency
            else {return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        return formatCurrency(marginBalanceBaseCurrency)
    }
    
    func getFormattedTotalValueWithPercentage() -> String{
        guard let totalValueBaseCurrency = fxBalance.totalValueBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        
        var formattedTotalValue = NumberFormatter.formatCurrency(totalValueBaseCurrency)

        let totalReturn = fxBalance.unrealizedProfitAndLossBaseCurrency?.floatValue
        if (totalReturn != nil && totalReturn != 0) {
            let totalPercentReturn = totalReturn! / (totalValueBaseCurrency.floatValue - abs(totalReturn!))
            formattedTotalValue += " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
        }
        return formattedTotalValue
    
    }
    
    func getFormattedBuyingPower() -> String {
        guard let buyingPowerBaseCurrency = fxBalance.buyingPowerBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER}
        return formatCurrency(buyingPowerBaseCurrency)
    }
    
    private func formatCurrency(currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
    }
}
