class TradeItPortfolioBalanceEquityPresenter {
    private let account: TradeItLinkedBrokerAccount
    private var balance: TradeItAccountOverview? {
        return account.balance
    }

    init(_ linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.account = linkedBrokerAccount
    }

    func numberOfRows() -> Int {
        return [
            self.balance?.totalValue != nil,
            self.hasTotalReturn(),
            self.hasDayReturn(),
            self.hasBuyingPower(),
            self.hasAvailableCash()
        ].filter { $0 == true }.count
    }

    func hasTotalReturn() -> Bool {
        return self.balance?.totalAbsoluteReturn != nil || self.balance?.totalPercentReturn != nil
    }

    func hasDayReturn() -> Bool {
        return self.balance?.dayAbsoluteReturn != nil || self.balance?.dayPercentReturn != nil
    }

    func hasAvailableCash() -> Bool {
        return self.balance?.availableCash != nil
    }

    func hasBuyingPower() -> Bool {
        return self.balance?.buyingPower != nil
    }

    func getFormattedTotalValue() -> String? {
        guard let totalValue = self.balance?.totalValue else { return nil }

        return NumberFormatter.formatCurrency(totalValue, currencyCode: balance?.accountBaseCurrency)
    }

    func getFormattedDayReturnWithPercentage() -> String? {
        var dayReturnString = ""

        if let dayAbsoluteReturn = self.balance?.dayAbsoluteReturn {
            dayReturnString = NumberFormatter.formatCurrency(dayAbsoluteReturn, displayVariance: true, currencyCode: balance?.accountBaseCurrency)
        }

        if let dayPercentReturn = self.balance?.dayPercentReturn {
            dayReturnString += " (" + NumberFormatter.formatPercentage(dayPercentReturn) + ")"
        }

        return dayReturnString.isEmpty ? nil : dayReturnString
    }

    func getDayReturnChangeColor() -> UIColor {
        let value = self.balance?.dayAbsoluteReturn ?? self.balance?.dayPercentReturn
        return TradeItPresenter.stockChangeColor(value?.doubleValue)
    }

    func getTotalReturnChangeColor() -> UIColor {
        let value = self.balance?.totalAbsoluteReturn ?? self.balance?.totalPercentReturn
        return TradeItPresenter.stockChangeColor(value?.doubleValue)
    }

    func getFormattedAvailableCash() -> String? {
        guard let availableCash = self.balance?.availableCash else {
            return nil
        }

        return NumberFormatter.formatCurrency(availableCash, currencyCode: balance?.accountBaseCurrency)
    }

    func getFormattedTotalReturnValueWithPercentage() -> String? {
        var totalReturnString = ""

        if let totalAbsoluteReturn = self.balance?.totalAbsoluteReturn {
            totalReturnString = NumberFormatter.formatCurrency(totalAbsoluteReturn, displayVariance: true, currencyCode: balance?.accountBaseCurrency)
        }

        if let totalPercentReturn = self.balance?.totalPercentReturn {
            totalReturnString = " (" + NumberFormatter.formatPercentage(totalPercentReturn) + ")"
        }

        return totalReturnString.isEmpty ? nil : totalReturnString
    }

    func getFormattedBuyingPower() -> String? {
        guard let buyingPower = self.balance?.buyingPower else {
            return nil
        }

        return NumberFormatter.formatCurrency(buyingPower, currencyCode: balance?.accountBaseCurrency)
    }

    func getFormattedTimestamp() -> String? {
        guard let timestamp = self.account.balanceLastUpdated else { return nil }

        return UpdateTimestampFormatter.displayString(forUpdateTimestamp: timestamp)
    }

    func getFormattedBuyingPowerLabel() -> String {
        return self.balance?.buyingPowerLabel ?? "Buying power"
    }

    func getFormattedBuyingPowerLabelWithTimestamp() -> String? {
        guard var label = self.getFormattedBuyingPower() else {
            return nil
        }

        if let timestamp = getFormattedTimestamp() {
            label += " as of \(timestamp)"
        }

        let buyingPowerLabel = getFormattedBuyingPowerLabel().uppercased()
        
        return (buyingPowerLabel + ": " + label)
    }

    func getFormattedTotalValueWithPercentage() -> String? {
        var formattedTotalValue = ""

        if let totalValue = self.balance?.totalValue {
            formattedTotalValue = NumberFormatter.formatCurrency(totalValue, currencyCode: balance?.accountBaseCurrency)
        }

        if let totalPercentReturn = self.balance?.totalPercentReturn {
            let formattedPercentage = NumberFormatter.formatPercentage(totalPercentReturn)
            (formattedTotalValue) += " (" + formattedPercentage + ")"
        }

        return formattedTotalValue.isEmpty ? nil : formattedTotalValue
    }
}
