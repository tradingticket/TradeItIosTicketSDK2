class TradeItPortfolioBalanceEquityPresenter {
    private var balance: TradeItAccountOverview?

    init(_ tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount) {
        if let balance = tradeItLinkedBrokerAccount.balance {
            self.balance = balance
        }
    }

    func getFormattedTotalValue() -> String {
        guard let totalValue = self.balance?.totalValue
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER}

        return NumberFormatter.formatCurrency(totalValue, currencyCode: balance?.accountBaseCurrency)
    }

    func getFormattedDayReturnWithPercentage() -> String {
        var dayReturnString = TradeItPresenter.MISSING_DATA_PLACEHOLDER

        if let dayAbsoluteReturn = self.balance?.dayAbsoluteReturn {
            dayReturnString = NumberFormatter.formatCurrency(dayAbsoluteReturn, variance: true, currencyCode: balance?.accountBaseCurrency)
        }

        if let dayPercentReturn = self.balance?.dayPercentReturn {
            dayReturnString += " (" + NumberFormatter.formatPercentage(dayPercentReturn) + ")"
        }

        return dayReturnString
    }

    func getFormattedAvailableCash() -> String {
        guard let availableCash = self.balance?.availableCash
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return NumberFormatter.formatCurrency(availableCash, currencyCode: balance?.accountBaseCurrency)
    }

    func getFormattedTotalReturnValueWithPercentage() -> String {
        var totalReturnString = TradeItPresenter.MISSING_DATA_PLACEHOLDER

        if let totalAbsoluteReturn = self.balance?.totalAbsoluteReturn {
            totalReturnString = NumberFormatter.formatCurrency(totalAbsoluteReturn, variance: true, currencyCode: balance?.accountBaseCurrency)
        }

        if let totalPercentReturn = self.balance?.totalPercentReturn {
            totalReturnString = " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
        }

        return totalReturnString
    }

    func getFormattedBuyingPower() -> String {
        guard let buyingPower = self.balance?.buyingPower
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return NumberFormatter.formatCurrency(buyingPower, currencyCode: balance?.accountBaseCurrency)
    }

    func getFormattedTotalValueWithPercentage() -> String {
        var formattedTotalValue = TradeItPresenter.MISSING_DATA_PLACEHOLDER

        if let totalValue = self.balance?.totalValue {
            formattedTotalValue = NumberFormatter.formatCurrency(totalValue, currencyCode: balance?.accountBaseCurrency)
        }

        if let totalPercentReturn = self.balance?.totalPercentReturn {
            formattedTotalValue += " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
        }

        return formattedTotalValue
    }
}
