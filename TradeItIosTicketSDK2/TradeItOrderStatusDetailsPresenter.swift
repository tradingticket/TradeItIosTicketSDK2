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
        let orderStatus = order.orderStatus
        let action = formatEnum(string: orderLeg?.action)
        let orderType = orderLeg?.priceInfo?.type ?? "UNKNOWN"
        
        var description: String = "\(action)"
        if (orderStatus == "FILLED") {
            let filledQuantity = orderLeg?.filledQuantity ?? 0
            let filledPrice = orderLeg?.fills?[safe: 0]?.price ?? 0
            description += " \(getFormattedQuantity(quantity: filledQuantity)) shares at \(getFormattedPrice(price:filledPrice))"
        } else {
            let orderedQuantity = orderLeg?.orderedQuantity ?? 0
            description += " \(getFormattedQuantity(quantity: orderedQuantity))"
            switch orderType {
            case "MARKET", "TRAILING_STOP_DOLLAR", "TRAILING_STOP_PRCT", "STOP":
                description += " shares at market price"
                break
            case "LIMIT":
                let limitPrice = orderLeg?.priceInfo?.limitPrice ?? 0
                description += " shares at \(getFormattedPrice(price:limitPrice))"
                break
            case "STOP_LIMIT":
                let stopPrice = orderLeg?.priceInfo?.stopPrice ?? 0
                description += " shares at \(getFormattedPrice(price:stopPrice))"
                break
            default: break
            }
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
        case "TRAILING_STOP_DOLLAR":
            let trailPrice = orderLeg?.priceInfo?.trailPrice ?? 0
            let trailPriceDollars = getFormattedPrice(price: trailPrice)
            if (action == "BUY") {
                description = "If price rises by \(trailPriceDollars)"
            } else {
                description = "If price drops by \(trailPriceDollars)"
            }
            break
        case "TRAILING_STOP_PRCT":
            let trailPrice = orderLeg?.priceInfo?.trailPrice ?? 0
            let trailPricePercentage = getFormattedPercentage(percentage: trailPrice)
            if (action == "BUY") {
                description = "If price rises by \(trailPricePercentage)"
            } else {
                description = "If price drops by \(trailPricePercentage)"
            }
            break
        default: break
        }
        return description
    }
    
    func getFormattedExpiration() -> String {
        let orderStatus = self.order.orderStatus ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
        switch orderStatus  {
        case "FILLED":
            let orderLeg = self.order.orderLegs?[safe: 0]
            return "Filled at \(getFormattedTimestamp(timestamp: orderLeg?.fills?[0].timestamp))"
        case "CANCELED", "REJECTED", "NOT_FOUND", "EXPIRED":
            return formatEnum(string: self.order.orderStatus)
        default:
            return formatEnum(string: order.orderExpiration)   
        }
    }
    
    private func formatEnum(string: String?) -> String {
        guard let string = string else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }
        return string.lowercased().capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    private func getFormattedQuantity(quantity: NSNumber) -> String {
        return quantity == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : "\(quantity)"
    }
    
    private func getFormattedPrice(price: NSNumber) -> String {
        return price == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(price)
    }
    
    private func getFormattedPercentage(percentage: NSNumber) -> String {
        return percentage == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatSimplePercentage(percentage)
    }
    
    private func getFormattedTimestamp(timestamp: String?) -> String {
        guard let timestamp = timestamp
            , let date = DateTimeFormatter.getDateFromString(timestamp) else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }
        return DateTimeFormatter.time(date, format: "h:mma")
    }
}
