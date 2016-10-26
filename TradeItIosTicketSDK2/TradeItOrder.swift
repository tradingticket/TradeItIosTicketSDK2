typealias TradeItPlaceOrderResult = TradeItPlaceTradeResult
typealias TradeItPlaceOrderHandlers = (_ onSuccess: @escaping (TradeItPlaceOrderResult) -> Void, _ onFailure: @escaping (TradeItErrorResult) -> Void) -> Void

open class TradeItOrder {
    open var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    open var symbol: String?
    open var action: TradeItOrderAction = TradeItOrderActionPresenter.DEFAULT
    open var type: TradeItOrderPriceType = TradeItOrderPriceTypePresenter.DEFAULT
    open var expiration: TradeItOrderExpiration = TradeItOrderExpirationPresenter.DEFAULT
    open var quantity: NSDecimalNumber?
    open var limitPrice: NSDecimalNumber?
    open var stopPrice: NSDecimalNumber?
    open var quoteLastPrice: NSDecimalNumber?

    public init() {}

    public init(linkedBrokerAccount: TradeItLinkedBrokerAccount, symbol: String) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.symbol = symbol
    }

    func requiresLimitPrice() -> Bool {
        return TradeItOrderPriceTypePresenter.LIMIT_TYPES.contains(type)
    }

    func requiresStopPrice() -> Bool {
        return TradeItOrderPriceTypePresenter.STOP_TYPES.contains(type)
    }

    func requiresExpiration() -> Bool {
        return TradeItOrderPriceTypePresenter.EXPIRATION_TYPES.contains(type)
    }

    func estimatedChange() -> NSDecimalNumber? {
        var optionalPrice: NSDecimalNumber?
        switch type {
        case .market: optionalPrice = quoteLastPrice
        case .limit: optionalPrice = limitPrice
        case .stopLimit: optionalPrice = limitPrice
        case .stopMarket: optionalPrice = stopPrice
        case .unknown: optionalPrice = 0.0
        }

        guard let quantity = quantity , quantity != NSDecimalNumber.notANumber else { return nil }
        guard let price = optionalPrice , price != NSDecimalNumber.notANumber else { return nil }

        return price.multiplying(by: quantity)
    }

    func preview(onSuccess: @escaping (TradeItPreviewTradeResult, @escaping TradeItPlaceOrderHandlers) -> Void,
                           onFailure: @escaping (TradeItErrorResult) -> Void
        ) -> Void {
        guard let linkedBrokerAccount = linkedBrokerAccount else {
            return onFailure(TradeItErrorResult(title: "Linked Broker Account", message: "A linked broker account must be set before you preview an order.")) }
        guard let previewPresenter = TradeItOrderPreviewPresenter(order: self) else {
            return onFailure(TradeItErrorResult(title: "Preview failed", message: "There was a problem previewing your order. Please try again."))
        }

        linkedBrokerAccount.tradeService.previewTrade(previewPresenter.generateRequest(), withCompletionBlock: { result in
            switch result {
            case let previewOrder as TradeItPreviewTradeResult:
                onSuccess(previewOrder, self.generatePlaceOrderCallback(tradeService: linkedBrokerAccount.tradeService, previewOrder: previewOrder))
            case let errorResult as TradeItErrorResult:
                linkedBrokerAccount.linkedBroker.error = errorResult
                onFailure(errorResult)
            default: onFailure(TradeItErrorResult(title: "Preview failed", message: "There was a problem previewing your order. Please try again."))
            }
        })
    }

    func isValid() -> Bool {
        return validateQuantity()
            && validateOrderPriceType()
            && symbol != nil
            && linkedBrokerAccount != nil
    }

    // MARK: Private

    fileprivate func validateQuantity() -> Bool {
        guard let quantity = quantity else { return false }
        return isGreaterThanZero(quantity)
    }

    fileprivate func validateOrderPriceType() -> Bool {
        switch type {
        case .market: return true
        case .limit: return validateLimit()
        case .stopMarket: return validateStopMarket()
        case .stopLimit: return validateStopLimit()
        case .unknown: return false
        }
    }

    fileprivate func validateLimit() -> Bool {
        guard let limitPrice = limitPrice else { return false }
        return isGreaterThanZero(limitPrice)
    }

    fileprivate func validateStopMarket() -> Bool {
        guard let stopPrice = stopPrice else { return false }
        return isGreaterThanZero(stopPrice)
    }

    fileprivate func validateStopLimit() -> Bool {
        return validateLimit() && validateStopMarket()
    }

    fileprivate func isGreaterThanZero(_ value: NSDecimalNumber) -> Bool {
        return value.compare(NSDecimalNumber(value: 0 as Int)) == .orderedDescending
    }

    fileprivate func generatePlaceOrderCallback(tradeService: TradeItTradeService, previewOrder: TradeItPreviewTradeResult) -> TradeItPlaceOrderHandlers {
        return { onSuccess, onFailure in
            let placeOrderRequest = TradeItPlaceTradeRequest(orderId: previewOrder.orderId)

            tradeService.placeTrade(placeOrderRequest) { result in
                switch result {
                case let placeOrderResult as TradeItPlaceTradeResult: onSuccess(placeOrderResult)
                case let errorResult as TradeItErrorResult: onFailure(errorResult)
                default: onFailure(TradeItErrorResult.tradeError(withSystemMessage: "Error placing order."))
                }
            }
        }
    }
}
