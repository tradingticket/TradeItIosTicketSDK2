extension TradeItOrderStatusDetails {
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
        case groupOpen = "GROUP_OPEN"
        case groupClosed = "GROUP_CLOSED"
        case expired = "EXPIRED"
        case unknown

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
    
    private typealias Category = [OrderStatus]
    private var openOrderCategory: Category {
        return  [.pending, .open, .pendingCancel, .groupOpen]
    }
    
    private var partiallyFilledCategory: Category {
        return [.partFilled]
    }
    
    private var filledOrderCategory: Category {
        return [.filled]
    }
    
    private var otherOrderCategory: Category {
        return [.cancelled, .rejected, .notFound, .expired, .groupClosed, .unknown]
    }
    
    func isGroupOrder() -> Bool {
        let groupOrders = self.groupOrders ?? []
        return groupOrders.count > 0
    }
    
    func isCancellable() -> Bool {
        return [.pending, .open, .partFilled, .pendingCancel, .groupOpen, .unknown].contains(self.orderStatusEnum)
    }
    
    func belongsToOpenCategory() -> Bool {
        return openOrderCategory.contains(self.orderStatusEnum)
    }
    
    func belongsToFilledCategory() -> Bool {
        return filledOrderCategory.contains(self.orderStatusEnum)
    }
    
    func belongsToOtherCategory() -> Bool {
        return otherOrderCategory.contains(self.orderStatusEnum)
    }
    
    func belongsToPartiallyFilledCategory() -> Bool {
        return partiallyFilledCategory.contains(self.orderStatusEnum)
    }
}
