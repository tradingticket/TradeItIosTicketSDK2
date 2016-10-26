class TradeItPortfolioBalanceEquityPresenter: TradeItPortfolioBalancePresenter {
    fileprivate var balance: TradeItAccountOverview?

    init(_ tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount) {
        if let balance = tradeItLinkedBrokerAccount.balance {
            self.balance = balance
        }
    }

    func getFormattedTotalValue() -> String {
        guard let totalValue = self.balance?.totalValue
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER}

        return NumberFormatter.formatCurrency(totalValue)
    }

    func getFormattedDayReturn() -> String {
        var dayReturnString = TradeItPresenter.MISSING_DATA_PLACEHOLDER

        if let dayAbsoluteReturn = self.balance?.dayAbsoluteReturn {
            dayReturnString = NumberFormatter.formatCurrency(dayAbsoluteReturn)
        }

        if let dayPercentReturn = self.balance?.dayPercentReturn {
            dayReturnString += " (" + NumberFormatter.formatPercentage(dayPercentReturn) + ")"
        }

        return dayReturnString
    }

    func getFormattedAvailableCash() -> String {
        guard let availableCash = self.balance?.availableCash
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER}

        return NumberFormatter.formatCurrency(availableCash)
    }

    func getFormattedTotalReturnValue() -> String {
        var totalReturnString = TradeItPresenter.MISSING_DATA_PLACEHOLDER

        if let totalAbsoluteReturn = self.balance?.totalAbsoluteReturn {
            totalReturnString = NumberFormatter.formatCurrency(totalAbsoluteReturn)
        }

        if let totalPercentReturn = self.balance?.totalPercentReturn {
            totalReturnString = " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
        }

        return totalReturnString
    }

    func getFormattedBuyingPower() -> String {
        guard let buyingPower = self.balance?.buyingPower
            else { return TradeItPresenter.MISSING_DATA_PLACEHOLDER }

        return NumberFormatter.formatCurrency(buyingPower)
    }

    func getFormattedTotalValueWithPercentage() -> String {
        var formattedTotalValue = TradeItPresenter.MISSING_DATA_PLACEHOLDER

        if let totalValue = self.balance?.totalValue {
            formattedTotalValue = NumberFormatter.formatCurrency(totalValue)
        }

        if let totalPercentReturn = self.balance?.totalPercentReturn {
            formattedTotalValue += " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
        }

        return formattedTotalValue
    }
}
