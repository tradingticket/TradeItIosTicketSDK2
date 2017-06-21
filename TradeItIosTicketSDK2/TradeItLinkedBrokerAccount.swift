@objc public class TradeItLinkedBrokerAccount: NSObject {
    public var brokerName: String? {
        return self.linkedBroker?.brokerName
    }

    public var accountName = ""
    public var accountNumber = ""
    public var accountBaseCurrency = ""
    public var balanceLastUpdated: Date?
    public var balance: TradeItAccountOverview?
    public var fxBalance: TradeItFxAccountOverview?
    public var positions: [TradeItPortfolioPosition] = []
    weak var linkedBroker: TradeItLinkedBroker?
    var tradeItBalanceService: TradeItBalanceService
    var tradeItPositionService: TradeItPositionService
    var tradeService: TradeItTradeService
    var fxTradeService: TradeItFxTradeService

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

    init(linkedBroker: TradeItLinkedBroker,
         accountName: String,
         accountNumber: String,
         accountBaseCurrency: String,
         balanceLastUpdated: Date? = nil,
         balance: TradeItAccountOverview?,
         fxBalance: TradeItFxAccountOverview?,
         positions: [TradeItPortfolioPosition],
         isEnabled: Bool=true) {
        self.linkedBroker = linkedBroker
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.accountBaseCurrency = accountBaseCurrency
        self.balanceLastUpdated = balanceLastUpdated
        self.balance = balance
        self.fxBalance = fxBalance
        self.positions = positions
        self._enabled = isEnabled
        self.tradeItBalanceService = TradeItBalanceService(session: linkedBroker.session)
        self.tradeItPositionService = TradeItPositionService(session: linkedBroker.session)
        self.tradeService = TradeItTradeService(session: linkedBroker.session)
        self.fxTradeService = TradeItFxTradeService(session: linkedBroker.session)
    }

    public func getAccountOverview(cacheResult: Bool = true,
                                   onSuccess: @escaping (TradeItAccountOverview?) -> Void,
                                   onFailure: @escaping (TradeItErrorResult) -> Void) {
        let request = TradeItAccountOverviewRequest(accountNumber: self.accountNumber)
        self.tradeItBalanceService.getAccountOverview(request) { tradeItResult in
            switch tradeItResult {
            case let accountOverviewResult as TradeItAccountOverviewResult:
                self.balanceLastUpdated = Date()
                self.balance = accountOverviewResult.accountOverview
                self.fxBalance = accountOverviewResult.fxAccountOverview
                self.linkedBroker?.clearError()

                if cacheResult {
                    TradeItSDK.linkedBrokerCache.cache(linkedBroker: self.linkedBroker)
                }

                onSuccess(accountOverviewResult.accountOverview)
            case let errorResult as TradeItErrorResult:
                self.linkedBroker?.error = errorResult
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult(title: "Failed to retrieve account balances"))
            }
        }
    }

    public func getPositions(onSuccess: @escaping ([TradeItPortfolioPosition]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let request = TradeItGetPositionsRequest(accountNumber: self.accountNumber)
        self.tradeItPositionService.getAccountPositions(request) { tradeItResult in
            switch tradeItResult {
            case let positionsResult as TradeItGetPositionsResult:
                let equityPositions = positionsResult.positions as! [TradeItPosition]
                let portfolioEquityPositions = equityPositions.map { equityPosition -> TradeItPortfolioPosition in
                    equityPosition.currencyCode = positionsResult.accountBaseCurrency
                    return TradeItPortfolioPosition(linkedBrokerAccount: self, position: equityPosition)
                }

                let fxPositions = positionsResult.fxPositions as! [TradeItFxPosition]
                let portfolioFxPositions = fxPositions.map { fxPosition -> TradeItPortfolioPosition in
                    return TradeItPortfolioPosition(linkedBrokerAccount: self, fxPosition: fxPosition)
                }

                self.positions = portfolioEquityPositions + portfolioFxPositions
                onSuccess(self.positions)
            case let errorResult as TradeItErrorResult:
                self.linkedBroker?.error = errorResult
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult(title: "Failed to retrieve account positions"))
            }
        }
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
}
