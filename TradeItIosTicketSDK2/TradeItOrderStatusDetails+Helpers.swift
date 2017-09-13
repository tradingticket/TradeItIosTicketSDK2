extension TradeItOrderStatusDetails {
    
    private var openOrderStatus: [String] {
        return  ["PENDING", "OPEN", "PART_FILLED", "PENDING_CANCEL"]
    }
    
    private var filledOrderStatus: [String] {
        return ["FILLED"]
    }
    private var otherOrderStatus: [String] {
        return ["CANCELED", "REJECTED", "NOT_FOUND", "EXPIRED"]
    }
    
    func containsOpenStatus() -> Bool {
        return isOrderStatusOneOf(orderStatus: openOrderStatus)
    }
    
    func containsFilledStatus() -> Bool {
        return isOrderStatusOneOf(orderStatus: filledOrderStatus)
    }
    
    func containsOtherOrderStatus() -> Bool {
        return isOrderStatusOneOf(orderStatus: otherOrderStatus)
    }
    
    func isGroupOrder() -> Bool {
        let groupOrders = self.groupOrders ?? []
        return groupOrders.count > 0
    }
    
    // MARK: private
    
    private func isOrderStatusOneOf(orderStatus: [String]) -> Bool {
        let containsSimpleStatusOrders = orderStatus.contains(self.orderStatus ?? "")
        
        guard let groupOrders = self.groupOrders, groupOrders.count > 0 else {
            return containsSimpleStatusOrders
        }
        
        return groupOrders.filter { $0.isOrderStatusOneOf(orderStatus: orderStatus) }.count > 0
    }

}
