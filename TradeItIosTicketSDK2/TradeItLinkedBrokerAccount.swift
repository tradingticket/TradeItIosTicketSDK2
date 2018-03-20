@objc public class TradeItLinkedBrokerAccount: NSObject {
    public var brokerName: String? {
        return self.linkedBroker?.brokerName
    }
    public var brokerLongName: String? {
        return self.linkedBroker?.brokerLongName
    }
    
    public var accountName = ""
    public var accountNumber = ""
    public var accountIndex = ""
    public var accountBaseCurrency = ""
    public var userCanDisableMargin: Bool
    public var balanceLastUpdated: Date?
    public var balance: TradeItAccountOverview?
    public var fxBalance: TradeItFxAccountOverview?
    public var positions: [TradeItPortfolioPosition] = []
    public var orders: [TradeItOrderStatusDetails] = []
    public var transactionsHistoryResult: TradeItTransactionsHistoryResult?
    public var orderCapabilities: [TradeItInstrumentOrderCapabilities] = []

    private weak var _linkedBroker: TradeItLinkedBroker?
    internal(set) public var linkedBroker: TradeItLinkedBroker? {
        get {
            return _linkedBroker
        }

        set(newValue) {
            _linkedBroker = newValue
        }
    }

    private var _enabled = true
    public var isEnabled: Bool {
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
    
    internal var tradeService: TradeItTradeService? {
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

    public func getAccountOverview(cacheResult: Bool = true,
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

    public func getPositions(onSuccess: @escaping ([TradeItPortfolioPosition]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
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

    public func getAllOrderStatus(onSuccess: @escaping ([TradeItOrderStatusDetails]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
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
    
    public func cancelOrder(orderNumber: String,
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
    
    public func getTransactionsHistory(onSuccess: @escaping (TradeItTransactionsHistoryResult) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
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
    
    public func getFormattedAccountName() -> String {
        var formattedAccountNumber = self.accountNumber
        var formattedAccountName = self.accountName
        var separator = " "

        if formattedAccountNumber.characters.count > 4 {
            let startIndex = formattedAccountNumber.characters.index(formattedAccountNumber.endIndex, offsetBy: -4)
            formattedAccountNumber = String(formattedAccountNumber.characters.suffix(from: startIndex))
            separator = "**"
        }

        if formattedAccountName.characters.count > 10 {
            formattedAccountName = String(formattedAccountName.characters.prefix(10))
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
