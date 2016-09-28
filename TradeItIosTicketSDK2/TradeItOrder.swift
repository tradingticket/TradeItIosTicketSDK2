class TradeItOrder {
    var orderAction: String?
    var orderType: String?
    var orderExpiration: String?
    var shares: NSDecimalNumber?
    var limitPrice: NSDecimalNumber?
    var stopPrice: NSDecimalNumber?
    var quoteLastPrice: NSDecimalNumber?

    func requiresLimitPrice() -> Bool {
        guard let orderType = orderType else { return false }
        return ["Limit", "Stop Limit"].contains(orderType)
    }

    func requiresStopPrice() -> Bool {
        guard let orderType = orderType else { return false }
        return ["Stop Market", "Stop Limit"].contains(orderType)
    }

    func requiresExpiration() -> Bool {
        guard let orderType = orderType else { return false }
        return orderType != "Market"
    }

    func estimatedChange() -> NSDecimalNumber? {
        guard let quoteLastPrice = quoteLastPrice,
            let shares = shares
            where shares != NSDecimalNumber.notANumber()
            else { return nil }

        return quoteLastPrice.decimalNumberByMultiplyingBy(shares)
    }

    func isValid() -> Bool {
        return validateQuantity() && validateOrderType()
    }

    private func validateQuantity() -> Bool {
        guard let shares = shares else { return false }
        return isGreaterThanZero(shares)
    }

    private func validateOrderType() -> Bool {
        guard let orderType = orderType else { return false }
        switch orderType {
        case "Market": return true
        case "Limit": return validateLimit()
        case "Stop Market": return validateStopMarket()
        case "Stop Limit": return validateStopLimit()
        default: return false
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
