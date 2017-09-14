public typealias TradeItPlaceOrderResult = TradeItPlaceTradeResult
public typealias TradeItPreviewOrderResult = TradeItPreviewTradeResult
public typealias TradeItPlaceOrderHandlers = (_ onSuccess: @escaping (TradeItPlaceOrderResult) -> Void,
                                              _ onFailure: @escaping (TradeItErrorResult) -> Void) -> Void

@objc public class TradeItOrder: NSObject {
    public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    public var symbol: String?
    public var action: TradeItOrderAction = TradeItOrderActionPresenter.DEFAULT
    public var type: TradeItOrderPriceType = TradeItOrderPriceTypePresenter.DEFAULT {
        didSet {
            if !requiresExpiration() {
                expiration = TradeItOrderExpirationPresenter.DEFAULT
            }
            if !requiresLimitPrice() {
                limitPrice = nil
            }
            if !requiresStopPrice() {
                stopPrice = nil
            }
        }
    }
    public var expiration: TradeItOrderExpiration? = TradeItOrderExpirationPresenter.DEFAULT
    public var quantity: NSDecimalNumber?
    public var limitPrice: NSDecimalNumber?
    public var stopPrice: NSDecimalNumber?
    public var quoteLastPrice: NSDecimalNumber?

    override public var description: String { return "TradeItOrder: account [\(self.linkedBrokerAccount?.accountName ?? "")/\(self.linkedBrokerAccount?.accountNumber ?? "")], symbol [\(self.symbol ?? "")], action [\(String(describing: self.action.rawValue))], type [\(String(describing:self.type.rawValue))], expiration [\(String(describing: self.expiration?.rawValue))], quantity [\(String(describing: self.quantity))], limitPrice [\(String(describing: self.limitPrice))], stopPrice [\(String(describing: self.stopPrice))], quote [\(String(describing: self.quoteLastPrice))]" }

    public override init() {
        super.init()
    }

    public init(linkedBrokerAccount: TradeItLinkedBrokerAccount? = nil,
                symbol: String? = nil,
                action: TradeItOrderAction = TradeItOrderActionPresenter.DEFAULT) {
        super.init()

        self.linkedBrokerAccount = linkedBrokerAccount
        self.symbol = symbol

        if action != .unknown {
            self.action = action
        }
    }

    public func requiresLimitPrice() -> Bool {
        let type = self.type
        return TradeItOrderPriceTypePresenter.LIMIT_TYPES.contains(type)
    }

    public func requiresStopPrice() -> Bool {
        let type = self.type
        return TradeItOrderPriceTypePresenter.STOP_TYPES.contains(type)
    }

    public func requiresExpiration() -> Bool {
        let type = self.type
        return TradeItOrderPriceTypePresenter.EXPIRATION_TYPES.contains(type)
    }

    public func estimatedChange() -> NSDecimalNumber? {
        var optionalPrice: NSDecimalNumber?
        let type = self.type
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

    public func preview(
        onSuccess: @escaping (TradeItPreviewTradeResult, @escaping TradeItPlaceOrderHandlers) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) -> Void {
        guard let linkedBrokerAccount = linkedBrokerAccount else {
            return onFailure(
                TradeItErrorResult(
                    title: "Missing Linked Broker Account",
                    message: "A linked broker account must be selected before you preview an order."
                )
            )
        }

        guard let previewPresenter = TradeItOrderPreviewPresenter(order: self) else {
            return onFailure(
                TradeItErrorResult(
                    title: "Preview failed",
                    message: "There was a problem previewing your order. Please try again."
                )
            )
        }

        linkedBrokerAccount.tradeService?.previewTrade(
            previewPresenter.generateRequest(),
            onSuccess: { result in
                onSuccess(
                    result,
                    self.generatePlaceOrderCallback(
                        tradeService: linkedBrokerAccount.tradeService,
                        previewOrderResult: result
                    )
                )
            }, onFailure: { error in
                linkedBrokerAccount.linkedBroker?.error = error
                onFailure(error)
            }
        )
    }

    public func isValid() -> Bool {
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
        let type = self.type
        switch type {
        case .market: return true
        case .limit: return validateLimit()
        case .stopMarket: return validateStopMarket()
        case .stopLimit: return validateStopLimit()
        case .unknown: return false
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

    private func isGreaterThanZero(_ value: NSDecimalNumber) -> Bool {
        return value.compare(NSDecimalNumber(value: 0 as Int)) == .orderedDescending
    }

    private func generatePlaceOrderCallback(tradeService: TradeItTradeService?, previewOrderResult: TradeItPreviewOrderResult) -> TradeItPlaceOrderHandlers {
        return { onSuccess, onFailure in
            let placeOrderRequest = TradeItPlaceTradeRequest(orderId: previewOrderResult.orderId)
            tradeService?.placeTrade(placeOrderRequest, onSuccess: onSuccess, onFailure: onFailure)
        }
    }
}
