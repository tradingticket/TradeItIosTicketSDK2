@objc public class TradeItFxOrder: NSObject {
    public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    public var symbol: String?
    public var amount: NSDecimalNumber?
    public var bidPrice: NSDecimalNumber?

    func isValid() -> Bool {
        return true // TODO
    }

    func estimatedChange() -> NSNumber? {
        return NSNumber.init(integerLiteral: 10)
    }

    public func place(
        onSuccess: @escaping (TradeItFxPlaceOrderResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        guard let linkedBrokerAccount = linkedBrokerAccount else {
            return onFailure(
                TradeItErrorResult(
                    title: "Linked Broker Account",
                    message: "A linked broker account must be selected before you place an order."
                )
            )
        }

        guard let placeOrderPresenter = TradeItFxPlaceOrderPresenter(order: self) else {
            return onFailure(
                TradeItErrorResult(
                    title: "Place order failed",
                    message: "There was a problem placing your order. Please try again."
                )
            )
        }

        linkedBrokerAccount.fxTradeService.place(
            order: placeOrderPresenter.generateRequest(),
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }
}


class TradeItFxPlaceOrderPresenter {
    let order: TradeItFxOrder

    init?(order: TradeItFxOrder) {
        if order.isValid() {
            self.order = order
        } else {
            return nil
        }
    }

    func generateRequest() -> TradeItFxPlaceOrderRequest {
        // TODO: DYNAMIC VALUES

        let orderLeg = TradeItFxOrderLeg()
        orderLeg.priceType = "MARKET"
        orderLeg.pair = "USD/AUD"
        orderLeg.action = "BUY"
        orderLeg.amount = 1000

        let fxOrderInfoInput = TradeItFxOrderInfoInput()
        fxOrderInfoInput.orderType = "SINGLE"
        fxOrderInfoInput.orderExpiration = "DAY"
        fxOrderInfoInput.orderLegs = [orderLeg]

        let request = TradeItFxPlaceOrderRequest()
        request.accountNumber = order.linkedBrokerAccount?.accountNumber
        request.fxOrderInfoInput = fxOrderInfoInput

        return request
    }

//    private func action() -> String {
//        switch order.action {
//        case .buy: return "buy"
//        case .sell: return "sell"
//        case .buyToCover: return "buyToCover"
//        case .sellShort: return "sellShort"
//        case .unknown: return "unknown"
//        }
//    }
//
//    private func priceType() -> String {
//        switch order.type {
//        case .market: return "market"
//        case .limit: return "limit"
//        case .stopLimit: return "stopLimit"
//        case .stopMarket: return "stopMarket"
//        case .unknown: return "unknown"
//        }
//    }
//
//    private func expiration() -> String {
//        switch order.expiration {
//        case .goodForDay: return "day"
//        case .goodUntilCanceled: return "gtc"
//        case .unknown: return "unknown"
//        }
//    }
//
//    private func quantity() -> NSDecimalNumber {
//        guard let quantity = order.quantity else { return 0 }
//        return quantity
//    }

    private func symbol() -> String {
        guard let symbol = order.symbol else { return "" }
        return symbol
    }
}
