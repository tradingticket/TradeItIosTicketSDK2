// TODO: Make these extensions public eventually...

internal extension TradeItPriceInfo {
    var priceTypeEnum: PriceType {
        return PriceType(rawValue: self.type ?? "") ?? .unknown
    }

    enum PriceType: String {
        case market = "MARKET"
        case limit = "LIMIT"
        case stop = "STOP"
        case stopLimit = "STOP_LIMIT"
        case netDebit = "NET_DEBIT"
        case trailingStopDollar = "TRAILING_STOP_DOLLAR"
        case trailingStopPercent = "TRAILING_STOP_PRCT"
        case unknown = "UNKNOWN"
    }
}

internal extension TradeItOrderLeg {
    var actionEnum: Action {
        return Action(rawValue: self.action ?? "") ?? .unknown
    }

    enum Action: String {
        case buy = "BUY"
        case buyOpen = "BUY_OPEN"
        case buyClose = "BUY_CLOSE"
        case buyToCover = "BUY_TO_COVER"
        case sell = "SELL"
        case sellOpen = "SELL_OPEN"
        case sellClose = "SELL_CLOSE"
        case sellShort = "SELL_SHORT"
        case unknown = "UNKNOWN"
    }
}

class TradeItOrderStatusDetailsPresenter: NSObject {
    private var orderStatusDetails: TradeItOrderStatusDetails
    private var orderLeg: TradeItOrderLeg?
    private var _isGroupOrderHeader: Bool
    private var _isGroupOrderChild: Bool
    
    public var isGroupOrderHeader: Bool {
            return self._isGroupOrderHeader
    }
    
    public var isGroupOrderChild: Bool {
        return self._isGroupOrderChild
    }
    
    init(orderStatusDetails: TradeItOrderStatusDetails, orderLeg: TradeItOrderLeg?, isGroupOrderHeader: Bool = false, isGroupOrderChild: Bool = false) {
        self.orderStatusDetails = orderStatusDetails
        self.orderLeg = orderLeg
        self._isGroupOrderHeader = isGroupOrderHeader
        self._isGroupOrderChild = isGroupOrderChild
    }
    
    func getOrderNumber() -> String? {
        if self.isGroupOrderHeader {
            return self.orderStatusDetails.groupOrderId
        } else {
            return self.orderStatusDetails.orderNumber
        }
    }
    
    func getGroupOrderHeaderTitle() -> String {
        guard let groupOrderType = self.orderStatusDetails.groupOrderType, isGroupOrderHeader else {
            return ""
        }
        return "Group order: \(formatEnum(string: groupOrderType))"
    }
    
    func isCancelable() -> Bool {
        return self.orderStatusDetails.isCancellable() && !self.isGroupOrderChild
    }
    
    func belongsToOpenCategory() -> Bool {
        return self.orderStatusDetails.belongsToOpenCategory()
    }
    
    func getSymbol() -> String {
        guard let symbol = self.orderLeg?.symbol else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }

        return symbol
    }
    
    func getFormattedDescription() -> String {
        return "\(actionDescription())\(quantityDescription())\(priceTypeDescription())"
    }
    
    func getFormattededOrderTypeDescription() -> String {
        let action = self.orderLeg?.actionEnum
        let orderPriceType = self.orderLeg?.priceInfo?.priceTypeEnum ?? .unknown
        var description: String = ""

        switch orderPriceType {
        case .stopLimit, .stop:
            let stopPrice = self.orderLeg?.priceInfo?.stopPrice ?? 0
            description = "Trigger: \(stopPrice == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(stopPrice))"
            break
        case .trailingStopDollar:
            let trailPrice = self.orderLeg?.priceInfo?.trailPrice ?? 0
            let trailPriceDollars = getFormattedPrice(price: trailPrice)

            if (action == .buy) {
                description = "If price rises by \(trailPriceDollars)"
            } else {
                description = "If price drops by \(trailPriceDollars)"
            }
            break
        case .trailingStopPercent:
            let trailPrice = self.orderLeg?.priceInfo?.trailPrice ?? 0
            let trailPricePercentage = getFormattedPercentage(percentage: trailPrice)

            if (action == .buy) {
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
        let orderStatus = self.orderStatusDetails.orderStatusEnum

        switch orderStatus  {
        case .filled:
            let timestamp = getFormattedTimestamp(timestamp: self.orderLeg?.fills?[safe: 0]?.timestamp ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER)
            return "Filled at \(timestamp)"
        default:
            return formatEnum(string: self.orderStatusDetails.orderExpiration)
        }
    }
    
    func getFormattedStatus() -> String {
        let orderStatus = self.orderStatusDetails.orderStatusEnum

        switch orderStatus  {
        case .filled:
            return ""
        default:
            return formatEnum(string: orderStatus.rawValue)
        }
    }

    func getCancelOrderPopupTitle() -> String {
        return self.isGroupOrderHeader ? "Cancel grouped orders?" : "Cancel order?"
    }

    func getCancelOrderPopupMessage() -> String {
        if self.isGroupOrderHeader {
            return "Cancel all orders in this group: \"\(formatEnum(string: self.orderStatusDetails.groupOrderType))\"?"
        } else {
            return "Cancel your order to \(getFormattedCancelMessageDescription())?"
        }
    }
    
    // MARK: private

    private func priceTypeDescription() -> String {
        let priceType = self.orderLeg?.priceInfo?.priceTypeEnum ?? .unknown

        switch priceType {
        case .market, .trailingStopDollar, .trailingStopPercent:
            return " at market price"
        case .limit:
            let limitPrice = getFormattedPrice(price: self.orderLeg?.priceInfo?.limitPrice ?? 0)
            return " at a limit of \(limitPrice)"
        case .stop:
            let stopPrice = getFormattedPrice(price: self.orderLeg?.priceInfo?.stopPrice ?? 0)
            return " at market price with a stop at \(stopPrice)"
        case .stopLimit:
            let limitPrice = getFormattedPrice(price: self.orderLeg?.priceInfo?.limitPrice ?? 0)
            let stopPrice = getFormattedPrice(price: self.orderLeg?.priceInfo?.stopPrice ?? 0)
            return " at a limit of \(limitPrice) with a stop at \(stopPrice)"
        default:
            return ""
        }
    }

    private func actionDescription() -> String {
        guard self.orderStatusDetails.orderStatusEnum == .filled else {
            return formatEnum(string: self.orderLeg?.action)
        }

        switch self.orderLeg?.actionEnum ?? .unknown {
        case .buy:
            return "Bought"
        case .buyOpen:
            return "Bought to open"
        case .buyClose:
            return "Bought to close"
        case .buyToCover:
            return "Bought to cover"
        case .sell:
            return "Sold"
        case .sellOpen:
            return "Sold to open"
        case .sellClose:
            return "Sold to close"
        case .sellShort:
            return "Sold short"
        case .unknown:
            return ""
        }
    }

    private func quantityDescription() -> String {
        var description = ""
        let orderedQuantity = self.orderLeg?.orderedQuantity ?? 0

        if (self.orderStatusDetails.orderStatusEnum == .partFilled) {
            let filledQuantity = self.orderLeg?.filledQuantity ?? 0
            let remainingShares = NSNumber(value: orderedQuantity.floatValue - filledQuantity.floatValue)
            description += " \(getFormattedQuantity(quantity: remainingShares)) remaining of"
        }

        description += " \(getFormattedQuantity(quantity: orderedQuantity)) shares"

        return description
    }

    private func getFormattedCancelMessageDescription() -> String {
        return "\(actionDescription())\(quantityDescription()) of \(getSymbol())\(priceTypeDescription())"
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
