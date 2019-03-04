class TradeItCryptoOrderPreviewPresenter {
    let order: TradeItCryptoOrder

    init?(order: TradeItCryptoOrder) {
        if order.isValid() {
            self.order = order
        } else {
            return nil
        }
    }

    func generateRequest() -> TradeItCryptoPreviewTradeRequest {
        let request = TradeItCryptoPreviewTradeRequest()

        request.accountNumber = order.linkedBrokerAccount?.accountNumber ?? ""
        request.orderAction = order.action.rawValue
        request.orderPriceType = order.type.rawValue
        request.orderExpiration = order.expiration.rawValue
        request.orderQuantity = quantity().doubleValue
        request.orderPair = order.symbol ?? ""
        request.orderLimitPrice = order.limitPrice?.doubleValue
        request.orderStopPrice = order.stopPrice?.doubleValue
        request.orderQuantityType = order.quantityType.rawValue

        return request
    }

    private func quantity() -> NSDecimalNumber {
        guard let quantity = order.quantity else { return 0 }
        return quantity
    }
}
