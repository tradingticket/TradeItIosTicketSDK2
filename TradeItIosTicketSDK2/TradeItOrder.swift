typealias TradeItPlaceOrderResult = TradeItPlaceTradeResult
typealias TradeItPlaceOrderHandlers = (onSuccess: (TradeItPlaceOrderResult) -> Void, onFailure: (TradeItErrorResult) -> Void) -> Void

public class TradeItOrder {
    public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    public var symbol: String?
    public var action: TradeItOrderAction = TradeItOrderActionPresenter.DEFAULT
    public var type: TradeItOrderPriceType = TradeItOrderPriceTypePresenter.DEFAULT
    public var expiration: TradeItOrderExpiration = TradeItOrderExpirationPresenter.DEFAULT
    public var quantity: NSDecimalNumber?
    public var limitPrice: NSDecimalNumber?
    public var stopPrice: NSDecimalNumber?
    public var quoteLastPrice: NSDecimalNumber?

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
        case .Market: optionalPrice = quoteLastPrice
        case .Limit: optionalPrice = limitPrice
        case .StopLimit: optionalPrice = limitPrice
        case .StopMarket: optionalPrice = stopPrice
        case .Unknown: optionalPrice = 0.0
        }

        guard let quantity = quantity where quantity != NSDecimalNumber.notANumber() else { return nil }
        guard let price = optionalPrice where price != NSDecimalNumber.notANumber() else { return nil }

        return price.decimalNumberByMultiplyingBy(quantity)
    }

    func preview(onSuccess onSuccess: (TradeItPreviewTradeResult, TradeItPlaceOrderHandlers) -> Void,
                           onFailure: (TradeItErrorResult) -> Void
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

    private func validateQuantity() -> Bool {
        guard let quantity = quantity else { return false }
        return isGreaterThanZero(quantity)
    }

    private func validateOrderPriceType() -> Bool {
        switch type {
        case .Market: return true
        case .Limit: return validateLimit()
        case .StopMarket: return validateStopMarket()
        case .StopLimit: return validateStopLimit()
        case .Unknown: return false
        }
    }

    private func validateLimit() -> Bool {
        guard let limitPrice = limitPrice else { return false }
        return isGreaterThanZero(limitPrice)
    }

    private func validateStopMarket() -> Bool {
        guard let stopPrice = stopPrice else { return false }
        return isGreaterThanZero(stopPrice)
    }

    private func validateStopLimit() -> Bool {
        return validateLimit() && validateStopMarket()
    }

    private func isGreaterThanZero(value: NSDecimalNumber) -> Bool {
        return value.compare(NSDecimalNumber(integer: 0)) == .OrderedDescending
    }

    private func generatePlaceOrderCallback(tradeService tradeService: TradeItTradeService, previewOrder: TradeItPreviewTradeResult) -> TradeItPlaceOrderHandlers {
        return { onSuccess, onFailure in
            let placeOrderRequest = TradeItPlaceTradeRequest(orderId: previewOrder.orderId)

            tradeService.placeTrade(placeOrderRequest) { result in
                switch result {
                case let placeOrderResult as TradeItPlaceTradeResult: onSuccess(placeOrderResult)
                case let errorResult as TradeItErrorResult: onFailure(errorResult)
                default: onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Error placing order."))
                }
            }
        }
    }
}
