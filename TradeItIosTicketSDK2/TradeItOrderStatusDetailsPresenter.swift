class TradeItOrderStatusDetailsPresenter: NSObject {
    private var order:TradeItOrderStatusDetails
    private var orderLeg:TradeItOrderLeg
    
    init(order: TradeItOrderStatusDetails, orderLeg: TradeItOrderLeg) {
        self.order = order
        self.orderLeg = orderLeg
    }
    
    func getSymbol() -> String {
        guard let symbol = self.orderLeg.symbol else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }
        return symbol
    }
    
    func getFormattedDescription() -> String {
        let orderStatus = self.order.orderStatus
        let action = formatEnum(string: self.orderLeg.action)
        let orderType = self.orderLeg.priceInfo?.type ?? "UNKNOWN"
        
        var description: String = "\(action)"
        if (orderStatus == "FILLED") {
            let filledQuantity = self.orderLeg.filledQuantity ?? 0 as NSNumber
            let filledPrice = self.orderLeg.fills?[safe: 0]?.price ?? 0 as NSNumber
            description += " \(getFormattedQuantity(quantity: filledQuantity)) shares at \(getFormattedPrice(price:filledPrice))"
        } else {
            let orderedQuantity = self.orderLeg.orderedQuantity ?? 0 as NSNumber
            description += " \(getFormattedQuantity(quantity: orderedQuantity))"
            switch orderType {
            case "MARKET", "TRAILING_STOP_DOLLAR", "TRAILING_STOP_PRCT", "STOP":
                description += " shares at market price"
                break
            case "LIMIT":
                let limitPrice = self.orderLeg.priceInfo?.limitPrice ?? 0 as NSNumber
                description += " shares at \(getFormattedPrice(price:limitPrice))"
                break
            case "STOP_LIMIT":
                let stopPrice = self.orderLeg.priceInfo?.stopPrice ?? 0 as NSNumber
                description += " shares at \(getFormattedPrice(price:stopPrice))"
                break
            default: break
            }
        }
        return description
    }
    
    func getFormattededOrderTypeDescription() -> String {
        let action = self.orderLeg.action ?? ""
        let orderType = self.orderLeg.priceInfo?.type ?? "UNKNOWN"
        var description: String = ""
        switch orderType {
        case "STOP_LIMIT", "STOP":
            let stopPrice = self.orderLeg.priceInfo?.stopPrice ?? 0 as NSNumber
            description = "Trigger: \(stopPrice == 0 as NSNumber ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(stopPrice))"
            break
        case "TRAILING_STOP_DOLLAR":
            let trailPrice = self.orderLeg.priceInfo?.trailPrice ?? 0 as NSNumber
            let trailPriceDollars = getFormattedPrice(price: trailPrice)
            if (action == "BUY") {
                description = "If price rises by \(trailPriceDollars)"
            } else {
                description = "If price drops by \(trailPriceDollars)"
            }
            break
        case "TRAILING_STOP_PRCT":
            let trailPrice = self.orderLeg.priceInfo?.trailPrice ?? 0 as NSNumber
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
            return "Filled at \(getFormattedTimestamp(timestamp: self.orderLeg.fills?[0].timestamp))"
        default:
            return formatEnum(string: self.order.orderExpiration)
        }
    }
    
    func getFormattedStatus() -> String {
        let orderStatus = self.order.orderStatus ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
        switch orderStatus  {
        case "FILLED":
            return ""
        default:
            return formatEnum(string: self.order.orderStatus)
        }
    }
    
    private func formatEnum(string: String?) -> String {
        guard let string = string else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }
        return string.lowercased().replacingOccurrences(of: "_", with: " ").capitalizingFirstLetter()
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
