@objc public class TradeItFxOrder: NSObject {
    public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    public var symbol: String?
    public var amount: NSDecimalNumber?
    public var bidPrice: NSDecimalNumber?
    public var actionType: String?
    public var priceType: String? {
        didSet {
            if !requiresExpiration() {
                expirationType = nil
            }
            if !requiresLimitPrice() {
                limitPrice = nil
            }
        }
    }
    public var expirationType: String?
    public var limitPrice: NSDecimalNumber?
    public var stopPrice: NSDecimalNumber?
    public var leverage: NSNumber?

    func isValid() -> Bool {
        return validateAmount()
//            && validatePriceType()
            && symbol != nil
            && linkedBrokerAccount != nil
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
        return priceType?.contains("limit") == true
    }

    public func requiresExpiration() -> Bool {
        return priceType?.contains("limit") == true
    }

    // MARK: Private

    private func validateAmount() -> Bool {
        guard let amount = amount else { return false }
        return isGreaterThanZero(amount)
    }

//    private func validateOrderPriceType() -> Bool {
//        switch type {
//        case .market: return true
//        case .limit: return validateLimit()
//        case .unknown: return false
//        }
//    }

    private func validateLimit() -> Bool {
        guard let limitPrice = limitPrice else { return false }
        return isGreaterThanZero(limitPrice)
    }

    private func isGreaterThanZero(_ value: NSDecimalNumber) -> Bool {
        return value.compare(NSDecimalNumber(value: 0 as Int)) == .orderedDescending
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
        orderLeg.pair = order.symbol
        orderLeg.action = order.actionType
        orderLeg.priceType = order.priceType
        orderLeg.amount = amount()
        orderLeg.rate = order.limitPrice
        orderLeg.leverage = order.leverage

        let fxOrderInfoInput = TradeItFxOrderInfoInput()
        fxOrderInfoInput.orderType = "SINGLE"
        fxOrderInfoInput.orderExpiration = order.expirationType
        fxOrderInfoInput.orderLegs = [orderLeg]

        let request = TradeItFxPlaceOrderRequest()
        request.accountNumber = order.linkedBrokerAccount?.accountNumber
        request.fxOrderInfoInput = fxOrderInfoInput

        return request
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
