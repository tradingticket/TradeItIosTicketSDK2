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

    fileprivate func action() -> String {
        switch order.action {
        case .buy: return "buy"
        case .sell: return "sell"
        case .buyToCover: return "buyToCover"
        case .sellShort: return "sellShort"
        case .unknown: return "unknown"
        }
    }

    fileprivate func priceType() -> String {
        switch order.type {
        case .market: return "market"
        case .limit: return "limit"
        case .stopLimit: return "stopLimit"
        case .stopMarket: return "stopMarket"
        case .unknown: return "unknown"
        }
    }

    fileprivate func expiration() -> String {
        switch order.expiration {
        case .goodForDay: return "day"
        case .goodUntilCanceled: return "gtc"
        case .unknown: return "unknown"
        }
    }

    fileprivate func quantity() -> NSDecimalNumber {
        guard let quantity = order.quantity else { return 0 }
        return quantity
    }

    fileprivate func symbol() -> String {
        guard let symbol = order.symbol else { return "" }
        return symbol
    }

    // TODO: Move this sort of thing to TradeItOrder. Maybe a computed property.
    private func limitPrice() -> NSDecimalNumber? {
        guard let limitPrice = order.limitPrice where order.requiresLimitPrice() else { return nil }

        return limitPrice
    }

    fileprivate func stopPrice() -> NSDecimalNumber? {
        guard let stopPrice = order.stopPrice where order.requiresStopPrice() else { return nil }

        return stopPrice
    }
}
