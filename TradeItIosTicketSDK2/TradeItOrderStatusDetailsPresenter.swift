class TradeItOrderStatusDetailsPresenter: NSObject {

    private var order:TradeItOrderStatusDetails
    
    init(order: TradeItOrderStatusDetails) {
        self.order = order
    }
    
    func getSymbol() -> String {
        guard let orderLeg = self.order.orderLegs?[safe: 0], let symbol = orderLeg.symbol else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }
        return symbol
    }
    
    func getFormattedDescription() -> String {
        let orderLeg = self.order.orderLegs?[safe: 0]
        let action = formatEnum(string: orderLeg?.action)
        let filledQuantity = orderLeg?.filledQuantity ?? 0
        let filledPrice = orderLeg?.fills?[safe: 0]?.price ?? 0
        let orderType = orderLeg?.priceInfo?.type ?? "UNKNOWN"
        var description: String = "\(action) \(filledQuantity)"
        switch orderType {
        case "MARKET", "TRAILING_STOP_DOLLAR", "STOP":
            description += " shares at market price"
            break
        case "LIMIT", "STOP_LIMIT", "TRAILING_STOP_PRCT":
            description += " shares at \(filledPrice == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(filledPrice))"
            break
        default: break
        }
        return description
    }
    
    func getFormattededOrderTypeDescription() -> String {
        let orderLeg = self.order.orderLegs?[safe: 0]
        let action = orderLeg?.action ?? ""
        let orderType = orderLeg?.priceInfo?.type ?? "UNKNOWN"
        var description: String = ""
        switch orderType {
        case "STOP_LIMIT", "STOP":
            let stopPrice = orderLeg?.priceInfo?.stopPrice ?? 0
            description = "Trigger: \(stopPrice == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(stopPrice))"
            break
        case "TRAILING_STOP_PRCT", "TRAILING_STOP_DOLLAR":
            let trailPrice = orderLeg?.priceInfo?.trailPrice ?? 0
            if (action == "BUY") {
                description = "If price drops by \(trailPrice == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(trailPrice))"
            } else {
                description = "If price drops by \(trailPrice == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(trailPrice))"
            }
            break
        default: break
        }
        return description
    }
    
    func getFormattedExpiration() -> String {
        return formatEnum(string: order.orderExpiration)
    }
    
    private func formatEnum(string: String?) -> String {
        guard let string = string else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }
        return string.lowercased().capitalized.replacingOccurrences(of: "_", with: " ")
    }
}
