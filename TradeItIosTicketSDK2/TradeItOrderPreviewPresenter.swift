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
        request.orderAction = action()
        request.orderPriceType = priceType()
        request.orderExpiration = expiration()
        request.orderQuantity = quantity()
        request.orderSymbol = symbol()
        request.orderLimitPrice = limitPrice()
        request.orderStopPrice = stopPrice()

        return request
    }

    private func action() -> String {
        switch order.action {
        case .Buy: return "buy"
        case .Sell: return "sell"
        case .BuyToCover: return "buyToCover"
        case .SellShort: return "sellShort"
        }
    }

    private func priceType() -> String {
        switch order.type {
        case .Market: return "market"
        case .Limit: return "limit"
        case .StopLimit: return "stopLimit"
        case .StopMarket: return "stopMarket"
        }
    }

    private func expiration() -> String {
        switch order.expiration {
        case .GoodForDay: return "day"
        case .GoodUntilCanceled: return "gtc"
        }
    }

    private func quantity() -> Int {
        guard let quantity = order.quantity else { return 0 }
        return quantity.integerValue
    }

    private func symbol() -> String {
        guard let symbol = order.symbol else { return "" }
        return symbol
    }

    // TODO: Move this sort of thing to TradeItOrder. Maybe a getter on the properties.
    private func limitPrice() -> NSNumber? {
        guard let limitPrice = order.limitPrice where order.requiresLimitPrice() else { return nil }

        return limitPrice
    }

    private func stopPrice() -> NSNumber? {
        guard let stopPrice = order.stopPrice where order.requiresStopPrice() else { return nil }

        return stopPrice
    }
}
