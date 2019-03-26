@objc public class TradeItCryptoOrder: NSObject {
    @objc public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
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
    @objc public var limitPrice: NSDecimalNumber?
    @objc public var stopPrice: NSDecimalNumber?
    @objc public var quoteLastPrice: NSDecimalNumber?
    internal var quantityType: OrderQuantityType = .quoteCurrency // Set to internal to get this out - will make enum obj-c compatible later

    var quantitySymbol: String? {
        get {
            switch quantityType {
            case .baseCurrency: return baseSymbol
            case .quoteCurrency: return quoteSymbol
            default: return nil
            }
        }
    }

    var estimateSymbol: String? {
        get {
            switch quantityType {
            case .baseCurrency: return quoteSymbol
            case .quoteCurrency: return baseSymbol
            default: return nil
            }
        }
    }

    private var _baseSymbol: String?
    var baseSymbol: String? {
        get {
            return _baseSymbol
        }
    }

    private var _quoteSymbol: String?
    var quoteSymbol: String? {
        get {
            return _quoteSymbol
        }
    }

    var _symbol: String?
    @objc public var symbol: String? {
        get {
            return _symbol
        }

        set(newValue) {
            guard let symbolPair = newValue?.components(separatedBy: ["/", "-"]),
                let baseSymbol = symbolPair.first,
                let quoteSymbol = symbolPair.last,
                symbolPair.count == 2
                else {
                    clearSymbol()
                    return
                }
            _symbol = newValue
            _baseSymbol = String(baseSymbol)
            _quoteSymbol = String(quoteSymbol)
        }
    }

    private func clearSymbol() {
        _symbol = nil
        _baseSymbol = nil
        _quoteSymbol = nil
    }

    override public var description: String {
        return "TradeItCryptoOrder: account [\(self.linkedBrokerAccount?.accountName ?? "")/\(self.linkedBrokerAccount?.accountNumber ?? "")], symbol [\(self.symbol ?? "")], action [\(String(describing: self.action.rawValue))], type [\(String(describing:self.type.rawValue))], expiration [\(String(describing: self.expiration.rawValue))], quantity [\(String(describing: self.quantity))], limitPrice [\(String(describing: self.limitPrice))], stopPrice [\(String(describing: self.stopPrice))], quote [\(String(describing: self.quoteLastPrice))], userDisabledMargin [\(String(describing: self.userDisabledMargin))]"
    }

    public override init() {
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
        var optionalTargetPrice: NSDecimalNumber?

        switch self.type {
        case .market: optionalTargetPrice = quoteLastPrice
        case .limit: optionalTargetPrice = limitPrice
        case .stopLimit: optionalTargetPrice = limitPrice
        case .stopMarket: optionalTargetPrice = stopPrice
        case .unknown: optionalTargetPrice = 0.0
        }

        guard let quantity = quantity,
            let targetPrice = optionalTargetPrice,
            quantity != NSDecimalNumber.notANumber,
            targetPrice != NSDecimalNumber.notANumber,
            targetPrice != NSDecimalNumber.zero
            else { return nil }

        switch quantityType {
        case .quoteCurrency, .totalPrice: return quantity.dividing(by: targetPrice)
        case .baseCurrency, .shares: return quantity.multiplying(by: targetPrice)
        }
    }

    func formattedEstimatedChange() -> String? {
        guard let estimatedChange = estimatedChange()?.doubleValue else { return nil }

        switch quantityType {
        case .quoteCurrency, .totalPrice:
            return NumberFormatter.formatQuantity(
                estimatedChange,
                maxDecimalPlaces: 6
            )
        case .baseCurrency, .shares:
            return NumberFormatter.formatQuantity(
                estimatedChange,
                maxDecimalPlaces: 6
            )
        }
    }

    @objc func preview(
        onSuccess: @escaping (TradeItCryptoPreviewTradeResult, @escaping TradeItPlaceOrderHandlers) -> Void,
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

        guard let previewPresenter = TradeItCryptoOrderPreviewPresenter(order: self) else {
            return onFailure(
                TradeItErrorResult(
                    title: "Preview failed",
                    message: "There was a problem previewing your order. Please try again."
                )
            )
        }

        self.linkedBrokerAccount?.cryptoTradeService?.previewTrade(
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
        previewOrderResult: TradeItCryptoPreviewTradeResult
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
                                self.linkedBrokerAccount?.cryptoTradeService?.answerSecurityQuestionPlaceOrder(securityQuestionAnswer, withCompletionBlock: handler)
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
            self.linkedBrokerAccount?.cryptoTradeService?.placeTrade(placeOrderRequest, withCompletionBlock: placeResponseHandler)
        }
    }
}
