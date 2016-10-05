class TradeItOrder {
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    var symbol: String?
    var action: TradeItOrderAction = TradeItOrderActionPresenter.DEFAULT
    var type: TradeItOrderPriceType = TradeItOrderPriceTypePresenter.DEFAULT
    var expiration: TradeItOrderExpiration = TradeItOrderExpirationPresenter.DEFAULT
    var shares: NSDecimalNumber?
    var limitPrice: NSDecimalNumber?
    var stopPrice: NSDecimalNumber?
    var quoteLastPrice: NSDecimalNumber?

    init() {}

    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, symbol: String) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.symbol = symbol
    }

    func requiresLimitPrice() -> Bool {
        return TradeItOrderPriceTypePresenter.LIMIT_TYPES.contains(type)
    }

    func requiresStopPrice() -> Bool {
        return TradeItOrderPriceTypePresenter.STOP_TYPES.contains(type)
    }

    func requiresExpiration() -> Bool {
        return TradeItOrderPriceTypePresenter.EXPIRATION_TYPES.contains(type)
    }

    func estimatedChange() -> NSDecimalNumber? {
        guard let quoteLastPrice = quoteLastPrice,
            let shares = shares
            where shares != NSDecimalNumber.notANumber()
            else { return nil }

        return quoteLastPrice.decimalNumberByMultiplyingBy(shares)
    }

    func isValid() -> Bool {
        return validateQuantity()
            && validateOrderPriceType()
            && symbol != nil
            && linkedBrokerAccount != nil
    }

    private func validateQuantity() -> Bool {
        guard let shares = shares else { return false }
        return isGreaterThanZero(shares)
    }

    private func validateOrderPriceType() -> Bool {
        switch type {
        case .Market: return true
        case .Limit: return validateLimit()
        case .StopMarket: return validateStopMarket()
        case .StopLimit: return validateStopLimit()
        }
    }

    private func validateLimit() -> Bool {
        guard let limitPrice = limitPrice else { return false }
        return isGreaterThanZero(limitPrice)
    }

    private func validateStopMarket() -> Bool {
        guard let stopPrice = stopPrice else { return false }
        return isGreaterThanZero(stopPrice)
    }

    private func validateStopLimit() -> Bool {
        return validateLimit() && validateStopMarket()
    }

    private func isGreaterThanZero(value: NSDecimalNumber) -> Bool {
        return value.compare(NSDecimalNumber(integer: 0)) == .OrderedDescending
    }
}
