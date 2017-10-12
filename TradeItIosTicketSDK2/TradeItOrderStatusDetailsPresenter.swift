// TODO: Make these extensions public eventually...

fileprivate extension TradeItPriceInfo {
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

fileprivate extension TradeItOrderLeg {
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

fileprivate extension TradeItOrderStatusDetails {
    var orderStatusEnum: OrderStatus {
        return OrderStatus(rawValue: self.orderStatus ?? "") ?? .unknown
    }

    var orderTypeEnum: OrderType {
        return OrderType(rawValue: self.orderType ?? "") ?? .unknown
    }

    enum OrderStatus: String {
        case pending = "PENDING"
        case open = "OPEN"
        case filled = "FILLED"
        case partFilled = "PART_FILLED"
        case cancelled = "CANCELED"
        case rejected = "REJECTED"
        case notFound = "NOT_FOUND"
        case pendingCancel = "PENDING_CANCEL"
        case expired = "EXPIRED"
        case unknown

        public var cancelable: Bool {
            return [.pending, .open, .partFilled, .pendingCancel, .unknown].contains(self)
        }
    }

    enum OrderType: String {
        case option = "OPTION"
        case equityOrEtf = "EQUITY_OR_ETF"
        case buyWrites = "BUY_WRITES"
        case spreads = "SPREADS"
        case combo = "COMBO"
        case multiLeg = "MULTILEG"
        case mutualFunds = "MUTUAL_FUNDS"
        case fixedIncome = "FIXED_INCOME"
        case cash = "CASH"
        case fx = "FX"
        case unknown = "UNKNOWN"
    }
}

class TradeItOrderStatusDetailsPresenter: NSObject {
    private var orderStatusDetails: TradeItOrderStatusDetails
    private var orderLeg: TradeItOrderLeg

    public var orderIsCancelable: Bool {
        return orderStatusDetails.orderStatusEnum.cancelable
    }

    init(orderStatusDetails: TradeItOrderStatusDetails, orderLeg: TradeItOrderLeg) {
        self.orderStatusDetails = orderStatusDetails
        self.orderLeg = orderLeg
    }

    func getSymbol() -> String {
        guard let symbol = self.orderLeg.symbol else {
            return TradeItPresenter.MISSING_DATA_PLACEHOLDER
        }

        return symbol
    }
    
    func getFormattedDescription() -> String {
        let action = formatEnum(string: self.orderLeg.action)
        let orderPriceType = self.orderLeg.priceInfo?.priceTypeEnum ?? .unknown

        var description: String = "\(action)"

        if (self.orderStatusDetails.orderStatusEnum == .filled) {
            let filledQuantity = self.orderLeg.filledQuantity ?? 0
            let filledPrice = self.orderLeg.fills?[safe: 0]?.price ?? 0
            description += " \(getFormattedQuantity(quantity: filledQuantity)) shares at \(getFormattedPrice(price:filledPrice))"
        } else {
            let orderedQuantity = self.orderLeg.orderedQuantity ?? 0
            description += " \(getFormattedQuantity(quantity: orderedQuantity))"

            switch orderPriceType {
            case .market, .trailingStopDollar, .trailingStopPercent, .stop:
                description += " shares at market price"
                break
            case .limit:
                let limitPrice = self.orderLeg.priceInfo?.limitPrice ?? 0
                description += " shares at \(getFormattedPrice(price:limitPrice))"
                break
            case .stopLimit:
                let stopPrice = self.orderLeg.priceInfo?.stopPrice ?? 0
                description += " shares at \(getFormattedPrice(price:stopPrice))"
                break
            default: break
            }
        }

        return description
    }
    
    func getFormattededOrderTypeDescription() -> String {
        let action = self.orderLeg.actionEnum
        let orderPriceType = self.orderLeg.priceInfo?.priceTypeEnum ?? .unknown
        var description: String = ""

        switch orderPriceType {
        case .stopLimit, .stop:
            let stopPrice = self.orderLeg.priceInfo?.stopPrice ?? 0
            description = "Trigger: \(stopPrice == 0 ? TradeItPresenter.MISSING_DATA_PLACEHOLDER : NumberFormatter.formatCurrency(stopPrice))"
            break
        case .trailingStopDollar:
            let trailPrice = self.orderLeg.priceInfo?.trailPrice ?? 0
            let trailPriceDollars = getFormattedPrice(price: trailPrice)

            if (action == .buy) {
                description = "If price rises by \(trailPriceDollars)"
            } else {
                description = "If price drops by \(trailPriceDollars)"
            }

            break
        case .trailingStopPercent:
            let trailPrice = self.orderLeg.priceInfo?.trailPrice ?? 0
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
            let timestamp = getFormattedTimestamp(timestamp: self.orderLeg.fills?[safe: 0]?.timestamp ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER)
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
