import TradeItIosEmsApi

class TradeItPortfolioBalanceFXPresenter: TradeItPortfolioBalancePresenter  {
    private var fxBalance: TradeItFxAccountOverview?

    init(_ tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount) {
        if let fxBalance = tradeItLinkedBrokerAccount.fxBalance {
            self.fxBalance = fxBalance
        }
    }

    func getFormattedTotalValue() -> String {
        guard let totalValueUSD = self.fxBalance?.totalValueUSD
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(totalValueUSD)
    }

    func getUnrealizedProfitAndLoss() -> String {
        guard let unrealizedProfitAndLossBaseCurrency = self.fxBalance?.unrealizedProfitAndLossBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(unrealizedProfitAndLossBaseCurrency)
    }
    
    func getRealizedProfitAndLoss() -> String {
        guard let realizedProfitAndLossBaseCurrency = self.fxBalance?.realizedProfitAndLossBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(realizedProfitAndLossBaseCurrency)
    }

    func getMarginBalance() -> String {
        guard let marginBalanceBaseCurrency = self.fxBalance?.marginBalanceBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(marginBalanceBaseCurrency)
    }

    func getFormattedTotalValueWithPercentage() -> String {
        guard let totalValueBaseCurrency = fxBalance?.totalValueBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        var formattedTotalValue = NumberFormatter.formatCurrency(totalValueBaseCurrency)

        formattedTotalValue += getFormattedTotalPercentage()

        return formattedTotalValue
    }

    func getFormattedBuyingPower() -> String {
        guard let buyingPowerBaseCurrency = self.fxBalance?.buyingPowerBaseCurrency
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return formatCurrency(buyingPowerBaseCurrency)
    }

    // MARK: Private

    private func getFormattedTotalPercentage() -> String {
        guard let totalValueBaseCurrency = fxBalance?.totalValueBaseCurrency?.floatValue
            , let totalReturn = fxBalance?.unrealizedProfitAndLossBaseCurrency?.floatValue where totalReturn != 0
            else { return "" }

        let totalPercentReturn = totalReturn / (totalValueBaseCurrency - totalReturn)
        return " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
    }

    private func formatCurrency(currency: NSNumber) -> String {
        return NumberFormatter.formatCurrency(currency, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
    }
}
