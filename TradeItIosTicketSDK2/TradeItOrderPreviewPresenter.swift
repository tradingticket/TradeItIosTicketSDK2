class TradeItOrderPreviewPresenter {
    let order: TradeItOrder

    init?(order: TradeItOrder) {
        if order.isValid() {
            self.order = order
        } else {
            return nil
        }
    }

    func generateRequest() -> TradeItPreviewTradeRequest {
        let request = TradeItPreviewTradeRequest()

        request.accountNumber = order.linkedBrokerAccount?.accountNumber
        request.orderAction = order.action.rawValue
        request.orderPriceType = order.type.rawValue
        request.orderExpiration = order.expiration.rawValue
        request.orderQuantity = quantity()
        request.orderQuantityType = order.quantityType.rawValue
        request.orderSymbol = symbol()
        request.orderLimitPrice = order.limitPrice
        request.orderStopPrice = order.stopPrice
        request.userDisabledMargin = order.userDisabledMargin
        return request
    }

    private func quantity() -> NSDecimalNumber {
        guard let quantity = order.quantity else { return 0 }
        return quantity
    }

    private func symbol() -> String {
        guard let symbol = order.symbol else { return "" }
        return symbol
    }
}
