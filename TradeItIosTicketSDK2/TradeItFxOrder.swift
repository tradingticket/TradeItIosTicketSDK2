@objc public class TradeItFxOrder: NSObject {
    public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    public var symbol: String?
    public var amount: NSDecimalNumber?
    public var bidPrice: NSDecimalNumber?
    public var action: TradeItFxOrderAction = TradeItFxOrderActionPresenter.DEFAULT
    public var type: TradeItFxOrderPriceType = TradeItFxOrderPriceTypePresenter.DEFAULT {
        didSet {
            if !requiresExpiration() {
                expiration = TradeItFxOrderExpirationPresenter.DEFAULT
            }
            if !requiresLimitPrice() {
                limitPrice = nil
            }
            if !requiresStopPrice() {
                stopPrice = nil
            }
        }
    }
    public var expiration: TradeItFxOrderExpiration = TradeItFxOrderExpirationPresenter.DEFAULT
    public var limitPrice: NSDecimalNumber?
    public var stopPrice: NSDecimalNumber?

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

    public func requiresLimitPrice() -> Bool {
        return TradeItFxOrderPriceTypePresenter.LIMIT_TYPES.contains(type)
    }

    public func requiresStopPrice() -> Bool {
        return TradeItFxOrderPriceTypePresenter.STOP_TYPES.contains(type)
    }

    public func requiresExpiration() -> Bool {
        return TradeItFxOrderPriceTypePresenter.EXPIRATION_TYPES.contains(type)
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
        let orderLeg = TradeItFxOrderLeg()
        orderLeg.priceType = priceType()
        orderLeg.pair = order.symbol
        orderLeg.action = action()
        orderLeg.amount = amount()

        let fxOrderInfoInput = TradeItFxOrderInfoInput()
        fxOrderInfoInput.orderType = "SINGLE"
        fxOrderInfoInput.orderExpiration = expiration()
        fxOrderInfoInput.orderLegs = [orderLeg]

        let request = TradeItFxPlaceOrderRequest()
        request.accountNumber = order.linkedBrokerAccount?.accountNumber
        request.fxOrderInfoInput = fxOrderInfoInput

        return request
    }

    private func action() -> String {
        switch order.action {
        case .buy: return "buy"
        case .sell: return "sell"
        case .unknown: return "unknown"
        }
    }

    private func priceType() -> String {
        switch order.type {
        case .market: return "market"
        case .limit: return "limit"
        case .stop: return "stop"
        case .unknown: return "unknown"
        }
    }

    private func expiration() -> String {
        switch order.expiration {
        case .goodForDay: return "day"
        case .goodUntilCanceled: return "good_till_cancel"
        case .immediateOrCancel: return "immediate_or_cancel"
        case .fillOrKill: return "fill_or_kill"
        case .unknown: return "unknown"
        }
    }

    private func amount() -> NSDecimalNumber {
        guard let amount = order.amount else { return 0 }
        return amount
    }

    private func symbol() -> String {
        guard let symbol = order.symbol else { return "" }
        return symbol
    }
}
