public class TradeItLinkedBrokerAccount: NSObject {
    public var brokerName = ""
    public var accountName = ""
    public var accountNumber = ""
    public var balance: TradeItAccountOverview?
    public var fxBalance: TradeItFxAccountOverview?
    public var positions: [TradeItPortfolioPosition] = []
    unowned var linkedBroker: TradeItLinkedBroker
    var tradeItBalanceService: TradeItBalanceService
    var tradeItPositionService: TradeItPositionService
    var tradeService: TradeItTradeService
    var isEnabled = true

    init(linkedBroker: TradeItLinkedBroker,
        brokerName: String,
         accountName: String,
         accountNumber: String,
         balance: TradeItAccountOverview!,
         fxBalance: TradeItFxAccountOverview!,
         positions: [TradeItPortfolioPosition]) {
        self.linkedBroker = linkedBroker
        self.brokerName = brokerName
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.balance = balance
        self.fxBalance = fxBalance
        self.positions = positions
        self.tradeItBalanceService = TradeItBalanceService(session: self.linkedBroker.session)
        self.tradeItPositionService = TradeItPositionService(session: self.linkedBroker.session)
        self.tradeService = TradeItTradeService(session: self.linkedBroker.session)
    }

    public func getAccountOverview(onSuccess onSuccess: () -> Void, onFailure: (TradeItErrorResult) -> Void) {
        let request = TradeItAccountOverviewRequest(accountNumber: self.accountNumber)
        self.tradeItBalanceService.getAccountOverview(request) { tradeItResult in
            switch tradeItResult {
            case let accountOverviewResult as TradeItAccountOverviewResult:
                self.balance = accountOverviewResult.accountOverview
                self.fxBalance = accountOverviewResult.fxAccountOverview
                onSuccess()
            case let errorResult as TradeItErrorResult:
                self.linkedBroker.error = errorResult
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Unknown error getting balances"))
            }
        }
    }

    public func getPositions(onSuccess onSuccess: () -> Void, onFailure: (TradeItErrorResult) -> Void) {
        let request = TradeItGetPositionsRequest(accountNumber: self.accountNumber)
        self.tradeItPositionService.getAccountPositions(request) { tradeItResult in
            switch tradeItResult {
            case let positionsResult as TradeItGetPositionsResult:
                var positionsPortfolio: [TradeItPortfolioPosition] = []

                let positions = positionsResult.positions as! [TradeItPosition]
                for position in positions {
                    let positionPortfolio = TradeItPortfolioPosition(linkedBrokerAccount: self, position: position)
                    positionsPortfolio.append(positionPortfolio)
                }

                let fxPositions = positionsResult.fxPositions as! [TradeItFxPosition]
                for fxPosition in fxPositions {
                    let positionPortfolio = TradeItPortfolioPosition(linkedBrokerAccount: self, fxPosition: fxPosition)
                    positionsPortfolio.append(positionPortfolio)
                }

                self.positions = positionsPortfolio
                onSuccess()
            case let errorResult as TradeItErrorResult:
                self.linkedBroker.error = errorResult
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Unknown error getting positions"))
            }
        }
    }

    public func getFormattedAccountName() -> String {
        var formattedAccountNumber = self.accountNumber
        var formattedAccountName = self.accountName
        var separator = " "
        if formattedAccountNumber.characters.count > 4 {
            let startIndex = formattedAccountNumber.endIndex.advancedBy(-4)
            formattedAccountNumber = String(formattedAccountNumber.characters.suffixFrom(startIndex))
            separator = "**"
        }

        if formattedAccountName.characters.count > 10 {
            formattedAccountName = String(formattedAccountName.characters.prefix(10))
            separator = "**"
        }

        return "\(formattedAccountName)\(separator)\(formattedAccountNumber)"
    }

}
