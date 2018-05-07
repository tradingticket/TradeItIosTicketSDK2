@objc public class TradeItLinkedBrokerAccount: NSObject {
    @objc public var brokerName: String? {
        return self.linkedBroker?.brokerName
    }
    @objc public var brokerLongName: String? {
        return self.linkedBroker?.brokerLongName
    }
    
    @objc public var accountName = ""
    @objc public var accountNumber = ""
    @objc public var accountIndex = ""
    @objc public var accountBaseCurrency = ""
    @objc public var userCanDisableMargin: Bool
    @objc public var balanceLastUpdated: Date?
    @objc public var balance: TradeItAccountOverview?
    @objc public var fxBalance: TradeItFxAccountOverview?
    @objc public var positions: [TradeItPortfolioPosition] = []
    @objc public var orders: [TradeItOrderStatusDetails] = []
    @objc public var transactionsHistoryResult: TradeItTransactionsHistoryResult?
    @objc public var orderCapabilities: [TradeItInstrumentOrderCapabilities] = []

    private weak var _linkedBroker: TradeItLinkedBroker?
    @objc public internal(set) var linkedBroker: TradeItLinkedBroker? {
        get {
            return _linkedBroker
        }

        set(newValue) {
            _linkedBroker = newValue
        }
    }

    private var _enabled = true
    @objc public var isEnabled: Bool {
        get {
            return _enabled
        }

        set(newValue) {
            if _enabled != newValue {
                _enabled = newValue
                TradeItSDK.linkedBrokerCache.cache(linkedBroker: self.linkedBroker)
            }
        }
    }
    
    private var balanceService: TradeItBalanceService? {
        return linkedBroker?.balanceService
    }
    
    private var positionService: TradeItPositionService? {
        return linkedBroker?.positionService
    }
    
    internal var tradeService: TradeItEquityTradeService? {
        return linkedBroker?.tradeService
    }
    
    internal var fxTradeService: TradeItFxTradeService? {
        return linkedBroker?.fxTradeService
    }
    
    private var orderService: TradeItOrderService? {
        return linkedBroker?.orderService
    }
    
    private var transactionService: TradeItTransactionService? {
        return linkedBroker?.transactionService
    }

    internal init(linkedBroker: TradeItLinkedBroker,
         accountName: String,
         accountNumber: String,
         accountIndex: String,
         accountBaseCurrency: String,
         userCanDisableMargin: Bool,
         balanceLastUpdated: Date? = nil,
         balance: TradeItAccountOverview?,
         fxBalance: TradeItFxAccountOverview?,
         positions: [TradeItPortfolioPosition],
         orderCapabilities: [TradeItInstrumentOrderCapabilities] = [],
         isEnabled: Bool=true
    ) {
        self._linkedBroker = linkedBroker
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.accountIndex = accountIndex
        self.accountBaseCurrency = accountBaseCurrency
        self.userCanDisableMargin = userCanDisableMargin
        self.balanceLastUpdated = balanceLastUpdated
        self.balance = balance
        self.fxBalance = fxBalance
        self.positions = positions
        self.orderCapabilities = orderCapabilities
        self._enabled = isEnabled
    }

    internal convenience init(linkedBroker: TradeItLinkedBroker, accountData: LinkedBrokerAccountData) {
        self.init(
            linkedBroker: linkedBroker,
            accountName: accountData.name,
            accountNumber: accountData.number,
            accountIndex: "",
            accountBaseCurrency: accountData.baseCurrency,
            userCanDisableMargin: accountData.userCanDisableMargin,
            balance: nil,
            fxBalance: nil,
            positions: []
        )
    }

    @objc public func getAccountOverview(cacheResult: Bool = true,
                                   onSuccess: @escaping (TradeItAccountOverview?) -> Void,
                                   onFailure: @escaping (TradeItErrorResult) -> Void) {
        let request = TradeItAccountOverviewRequest(accountNumber: self.accountNumber)
        self.balanceService?.getAccountOverview(request, onSuccess: { result in
            self.balanceLastUpdated = Date()
            self.balance = result.accountOverview
            self.fxBalance = result.fxAccountOverview
            self.linkedBroker?.clearError()

            if cacheResult {
                TradeItSDK.linkedBrokerCache.cache(linkedBroker: self.linkedBroker)
            }

            onSuccess(result.accountOverview)
        }, onFailure: { error in
            self.setError(error)
            onFailure(error)
        })
    }

    @objc public func getPositions(onSuccess: @escaping ([TradeItPortfolioPosition]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let request = TradeItGetPositionsRequest(accountNumber: self.accountNumber)

        self.positionService?.getPositions(request, onSuccess: { result in
            guard let equityPositions = result.positions as? [TradeItPosition] else {
                return onFailure(TradeItErrorResult(title: "Could not retrieve account positions. Please try again."))
            }
            let portfolioEquityPositions = equityPositions.map { equityPosition -> TradeItPortfolioPosition in
                return TradeItPortfolioPosition(linkedBrokerAccount: self, position: equityPosition)
            }

            guard let fxPositions = result.fxPositions as? [TradeItFxPosition] else {
                return onFailure(TradeItErrorResult(title: "Could not retrieve account positions. Please try again."))
            }
            let portfolioFxPositions = fxPositions.map { fxPosition -> TradeItPortfolioPosition in
                return TradeItPortfolioPosition(linkedBrokerAccount: self, fxPosition: fxPosition)
            }

            self.positions = portfolioEquityPositions + portfolioFxPositions
            onSuccess(self.positions)
        }, onFailure: { error in
            self.setError(error)
            onFailure(error)
        })
    }

    @objc public func getAllOrderStatus(onSuccess: @escaping ([TradeItOrderStatusDetails]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let request = TradeItAllOrderStatusRequest()
        request.accountNumber = self.accountNumber
        
        self.orderService?.getAllOrderStatus(request, onSuccess: { result in
            self.orders = result.orderStatusDetailsList ?? []
            onSuccess(self.orders)
        }, onFailure: { error in
            self.setError(error)
            onFailure(error)
        })
    }
    
    @objc public func cancelOrder(orderNumber: String,
                            onSuccess: @escaping () -> Void,
                            onSecurityQuestion: @escaping (
                                TradeItSecurityQuestionResult,
                                _ submitAnswer: @escaping (String) -> Void,
                                _ onCancelSecurityQuestion: @escaping () -> Void
                            ) -> Void,
                            onFailure: @escaping (TradeItErrorResult) -> Void) {
        let request = TradeItCancelOrderRequest()
        request.accountNumber = self.accountNumber
        request.orderNumber = orderNumber
        self.orderService?.cancelOrder(
            request,
            onSuccess: onSuccess,
            onSecurityQuestion: onSecurityQuestion,
            onFailure: { error in
                self.setError(error)
                onFailure(error)
            }
        )
    }
    
    @objc public func getTransactionsHistory(onSuccess: @escaping (TradeItTransactionsHistoryResult) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let request = TradeItTransactionsHistoryRequest()
        request.accountNumber = self.accountNumber
        
        self.transactionService?.getTransactionsHistory(request, onSuccess: { result in
            self.transactionsHistoryResult = result
            onSuccess(result)
        }, onFailure: { error in
            self.setError(error)
            onFailure(error)
        })
    }
    
    @objc public func getFormattedAccountName() -> String {
        var formattedAccountNumber = self.accountNumber
        var formattedAccountName = self.accountName
        var separator = " "

        if formattedAccountNumber.count > 4 {
            let startIndex = formattedAccountNumber.index(formattedAccountNumber.endIndex, offsetBy: -4)
            formattedAccountNumber = String(formattedAccountNumber.suffix(from: startIndex))
            separator = "**"
        }

        if formattedAccountName.count > 10 {
            formattedAccountName = String(formattedAccountName.prefix(10))
            separator = "**"
        }

        return "\(formattedAccountName)\(separator)\(formattedAccountNumber)"
    }

    internal func orderCapabilities(forInstrument instrument: TradeItTradeInstrumentType) -> TradeItInstrumentOrderCapabilities? {
        return self.orderCapabilities.first { instrumentCapabilities in
            return instrumentCapabilities.instrument == instrument.rawValue.lowercased()
        }
    }
    
    // MARK: private
    
    private func setError(_ error: TradeItErrorResult) {
        if error.requiresRelink() || error.requiresAuthentication() {
            linkedBroker?.error = error
        }
    }
}
