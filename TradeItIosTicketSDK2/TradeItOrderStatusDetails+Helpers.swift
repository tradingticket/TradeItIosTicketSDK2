extension TradeItOrderStatusDetails {
    private typealias Category = [String]
    private var openOrderCategory: Category {
        return  ["PENDING", "OPEN", "PENDING_CANCEL"]
    }
    
    private var partiallyFilledCategory: Category {
        return ["PART_FILLED"]
    }
    
    private var filledOrderCategory: Category {
        return ["FILLED"]
    }
    private var otherOrderCategory: Category {
        return ["CANCELED", "REJECTED", "NOT_FOUND", "EXPIRED"]
    }
    
    func belongsToOpenCategory() -> Bool {
        return belongsToCategory(orderCategory: openOrderCategory)
    }
    
    func belongsToFilledCategory() -> Bool {
        return belongsToCategory(orderCategory: filledOrderCategory)
    }
    
    func belongsToOtherCategory() -> Bool {
        return belongsToCategory(orderCategory: otherOrderCategory)
    }
    
    func belongsToPartiallyFilledCategory() -> Bool {
        return belongsToCategory(orderCategory: partiallyFilledCategory)
    }
    
    func isGroupOrder() -> Bool {
        let groupOrders = self.groupOrders ?? []
        return groupOrders.count > 0
    }
    
    // MARK: private
    
    private func belongsToCategory(orderCategory: Category) -> Bool {
        guard let groupOrders = self.groupOrders, groupOrders.count > 0 else {
            return orderCategory.contains(self.orderStatus ?? "")
        }
        
        //Group orders specificity
        if orderCategory == partiallyFilledCategory { // Group orders belong to partially filled category if at least one order is filled and one other is different than filled
            let belongsToFilledOrder = groupOrders.filter { $0.belongsToFilledCategory() }.count > 0
            let belongsToOtherThanFilledOrders = groupOrders.filter { !$0.belongsToFilledCategory() }.count > 0
            return belongsToFilledOrder && belongsToOtherThanFilledOrders
        } else if orderCategory == otherOrderCategory { // Group orders belong to otherOrderCategory category if at least 2 legs are different and not filled
            let belongsToOpenCategory = groupOrders.filter { $0.belongsToOpenCategory() }.count > 0
            let belongsToPartiallyFilledCategory = groupOrders.filter { $0.belongsToPartiallyFilledCategory() }.count > 0
            let belongsToOtherCategory = groupOrders.filter { $0.belongsToOtherCategory() }.count > 0
            let belongsToDifferentCategoriesOtherThanFilled = ( belongsToOpenCategory && belongsToOtherCategory
                || belongsToOpenCategory && belongsToPartiallyFilledCategory
                || belongsToOtherCategory && belongsToPartiallyFilledCategory
            )
            let belongsToFilledCategory = groupOrders.filter { $0.belongsToFilledCategory() }.count > 0
            return belongsToDifferentCategoriesOtherThanFilled && !belongsToFilledCategory
        } else { // Group orders belong to a category if all of the legs belong to the same category
            let belongsToCategory = groupOrders.filter { $0.belongsToCategory(orderCategory: orderCategory) }.count > 0
            let belongsToAnOtherCategory = groupOrders.filter { !$0.belongsToCategory(orderCategory: orderCategory) }.count > 0
            return belongsToCategory && !belongsToAnOtherCategory
        }
    }
}
