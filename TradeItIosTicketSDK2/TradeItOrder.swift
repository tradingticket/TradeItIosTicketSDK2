public typealias TradeItPlaceOrderResult = TradeItPlaceTradeResult
public typealias TradeItPreviewOrderResult = TradeItPreviewTradeResult
public typealias TradeItPlaceOrderHandlers = (
    _ onSuccess: @escaping (TradeItPlaceOrderResult) -> Void,
    _ onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
        _ submitAnswer: @escaping (String) -> Void,
        _ onCancelSecurityQuestion: @escaping () -> Void
    ) -> Void,
    _ onFailure: @escaping (TradeItErrorResult) -> Void
) -> Void

@objc public class TradeItOrder: NSObject {
    @objc public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    @objc public var symbol: String?
    @objc public var action: TradeItOrderAction = TradeItOrderActionPresenter.DEFAULT
    @objc public var type: TradeItOrderPriceType = TradeItOrderPriceTypePresenter.DEFAULT {
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
    @objc public var expiration: TradeItOrderExpiration = TradeItOrderExpirationPresenter.DEFAULT
    @objc public var userDisabledMargin = false
    @objc public var quantity: NSDecimalNumber?
    internal var quantityType: OrderQuantityType? // Set to internal to get this out - will make enum obj-c compatible later
    @objc public var limitPrice: NSDecimalNumber?
    @objc public var stopPrice: NSDecimalNumber?
    @objc public var quoteLastPrice: NSDecimalNumber?

    var tradeService: TradeItEquityTradeService? {
        return linkedBrokerAccount?.equityTradeService
    }

    @objc override public var description: String { return "TradeItOrder: account [\(self.linkedBrokerAccount?.accountName ?? "")/\(self.linkedBrokerAccount?.accountNumber ?? "")], symbol [\(self.symbol ?? "")], action [\(String(describing: self.action.rawValue))], type [\(String(describing:self.type.rawValue))], expiration [\(String(describing: self.expiration.rawValue))], quantity [\(String(describing: self.quantity))], limitPrice [\(String(describing: self.limitPrice))], stopPrice [\(String(describing: self.stopPrice))], quote [\(String(describing: self.quoteLastPrice))], userDisabledMargin [\(String(describing: self.userDisabledMargin))]" }

    @objc public override init() {
        super.init()
    }

    @objc public init(
        linkedBrokerAccount: TradeItLinkedBrokerAccount? = nil,
        symbol: String? = nil,
        action: TradeItOrderAction = TradeItOrderActionPresenter.DEFAULT
    ) {
        super.init()

        self.linkedBrokerAccount = linkedBrokerAccount
        self.symbol = symbol

        if action != .unknown {
            self.action = action
        }
    }

    @objc public func requiresLimitPrice() -> Bool {
        return TradeItOrderPriceTypePresenter.LIMIT_TYPES.contains(type)
    }

    @objc public func requiresStopPrice() -> Bool {
        return TradeItOrderPriceTypePresenter.STOP_TYPES.contains(type)
    }

    @objc public func requiresExpiration() -> Bool {
        return TradeItOrderPriceTypePresenter.EXPIRATION_TYPES.contains(type)
    }
    
    @objc public func userCanDisableMargin() -> Bool {
        return self.linkedBrokerAccount?.userCanDisableMargin ?? false
    }

    @objc public func estimatedChange() -> NSDecimalNumber? {
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

    @objc public func preview(
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

        self.linkedBrokerAccount?.equityTradeService?.previewTrade(
            previewPresenter.generateRequest(),
            onSuccess: { result in
                onSuccess(
                    result,
                    self.generatePlaceOrderCallback(
                        previewOrderResult: result
                    )
                )
            }, onFailure: { error in
                linkedBrokerAccount.linkedBroker?.error = error
                onFailure(error)
            }
        )
    }

    @objc public func isValid() -> Bool {
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

    private func generatePlaceOrderCallback(
        previewOrderResult: TradeItPreviewOrderResult
    ) -> TradeItPlaceOrderHandlers {
        return { onSuccess, onSecurityQuestion, onFailure in
            let placeOrderRequest = TradeItPlaceTradeRequest(orderId: previewOrderResult.orderId)
            let placeResponseHandler = YCombinator { handler in
                { (result: TradeItResult?) in
                    switch result {
                    case let placeOrderResult as TradeItPlaceOrderResult:
                        onSuccess(placeOrderResult)
                    case let securityQuestion as TradeItSecurityQuestionResult:
                        onSecurityQuestion(
                            securityQuestion,
                            { securityQuestionAnswer in
                                self.linkedBrokerAccount?.equityTradeService?.answerSecurityQuestionPlaceOrder(securityQuestionAnswer, withCompletionBlock: handler)
                            },
                            {
                                handler(
                                    TradeItErrorResult(
                                        title: "Authentication failed",
                                        message: "The security question was canceled.",
                                        code: .sessionError
                                    )
                                )
                            }
                        )
                    case let errorResult as TradeItErrorResult:
                        onFailure(errorResult)
                    default:
                        onFailure(TradeItErrorResult.tradeError(withSystemMessage: "Error placing order."))
                    }
                }
            }
            self.linkedBrokerAccount?.equityTradeService?.placeTrade(placeOrderRequest, withCompletionBlock: placeResponseHandler)
        }
    }
}
