import PromiseKit

@objc public class TradeItLinkedBroker: NSObject {
    public var accountsLastUpdated: Date?
    public var accounts: [TradeItLinkedBrokerAccount] = []
    private var _error: TradeItErrorResult?
    var error: TradeItErrorResult? {
        set(newError) {
            guard newError?.errorCode != .brokerExecutionError,
                newError?.errorCode != .paramsError
            else {
                return
            }

            self._error = newError
            self.isAccountLinkDelayedError = newError?.isAccountLinkDelayedError() ?? false
        }
        get { return self._error }
    }
    public var isAccountLinkDelayedError: Bool = false
    
    var session: TradeItSession
    var linkedLogin: TradeItLinkedLogin

    public var brokerName: String {
        return self.linkedLogin.broker ?? "Missing Broker Name"
    }

    public init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        self.session = session
        self.linkedLogin = linkedLogin
        super.init()
        
        self.setUnauthenticated()
    }

    public func clearError() {
        self.error = nil
    }

    public func authenticate(
        onSuccess: @escaping () -> Void,
        onSecurityQuestion: @escaping (
            TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void
        ) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) -> Void {
        let authenticationResponseHandler = YCombinator { handler in
            { (tradeItResult: TradeItResult) in
                switch tradeItResult {
                case let authenticationResult as TradeItAuthenticationResult:
                    self.clearError()

                    let accounts = authenticationResult.accounts as! [TradeItBrokerAccount]

                    self.updateLinkedBrokerAccounts(fromBrokerAccounts: accounts)

                    TradeItSDK.linkedBrokerCache.cache(linkedBroker: self)

                    onSuccess()
                case let securityQuestion as TradeItSecurityQuestionResult:
                    onSecurityQuestion(
                        securityQuestion,
                        { securityQuestionAnswer in
                            self.session.answerSecurityQuestion(securityQuestionAnswer, withCompletionBlock: handler)
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
                case let error as TradeItErrorResult:
                    self.error = error
                    if self.isAccountLinkDelayedError { // We need to cache the isAccountLinkDelayedError property to be able to show the error when we relaunch the app 
                        TradeItSDK.linkedBrokerCache.cache(linkedBroker: self)
                    }
                    onFailure(error)
                default:
                    handler(
                        TradeItErrorResult(
                            title: "Authentication failed",
                            code: .sessionError
                        )
                    )
                }
            }
        }

        self.session.authenticate(linkedLogin, withCompletionBlock: authenticationResponseHandler)
    }

    public func authenticateIfNeeded(
        onSuccess: @escaping () -> Void,
        onSecurityQuestion: @escaping (
            TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void
        ) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) -> Void {
        guard let error = self.error else {
                onSuccess()
                return
        }

        if error.requiresAuthentication() {
            self.authenticate(onSuccess: onSuccess, onSecurityQuestion: onSecurityQuestion, onFailure: onFailure)
        } else if error.requiresRelink() {
            onFailure(error)
        } else {
            onSuccess()
        }
    }

    public func refreshAccountBalances(
        force: Bool = true,
        cacheResult: Bool = true,
        onFinished: @escaping () -> Void
    ) {
        let promises = accounts.filter { account in
            return force || (account.balance == nil && account.fxBalance == nil)
        }.map { account in
            return Promise<Void> { fulfill, reject in
                account.getAccountOverview(
                    cacheResult: false, // Cache at the end so we don't cache the entire linked broker multiple times
                    onSuccess: { _ in
                        fulfill()
                    },
                    onFailure: { errorResult in
                        fulfill()
                    }
                )
            }
        }

        _ = when(resolved: promises).always {
            if cacheResult {
                TradeItSDK.linkedBrokerCache.cache(linkedBroker: self)
            }
            onFinished()
        }
    }

    public func getEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.accounts.filter { return $0.isEnabled }
    }

    public func isStillLinked() -> Bool {
        let linkedBrokers = TradeItSDK.linkedBrokerManager.linkedBrokers
        return linkedBrokers.index(of: self) != nil
    }

    public func findAccount(byAccountNumber accountNumber: String) -> TradeItLinkedBrokerAccount? {
        let matchingAccounts = self.accounts.filter { (account: TradeItLinkedBrokerAccount) -> Bool in
            return account.accountNumber == accountNumber
        }

        return matchingAccounts.first
    }

    public func setUnauthenticated() {
        self.error = TradeItErrorResult(
            title: "Linked Broker initialized from keychain",
            message: "This linked broker needs to authenticate.",
            code: .sessionError
        )
    }

    public func getFxQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let data = TradeItFxQuoteRequest()
        data.symbol = symbol
        data.token = self.session.token

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "brokermarketdata/getFxRate",
            environment: self.session.connector.environment
        )

        self.session.connector.sendEMSRequest(request, forResultClass: TradeItQuotesResult.self, withCompletionBlock: { result in
            if let quotesResult = result as? TradeItQuotesResult,
                let quote = quotesResult.quotes?.first as? TradeItQuote {
                onSuccess(quote)
            } else if let errorResult = result as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Market Data failed", message: "Fetching the quote failed. Please try again later."))
            }
        })
    }

    // MARK: Private

    private func updateLinkedBrokerAccounts(fromBrokerAccounts accounts: [TradeItBrokerAccount]) {
        let newLinkedBrokerAccounts = accounts.map { account -> TradeItLinkedBrokerAccount in
            let accountEnabled = findAccount(byAccountNumber: account.accountNumber)?.isEnabled ?? true

            let linkedBrokerAccount = TradeItLinkedBrokerAccount(
                linkedBroker: self,
                accountName: account.name,
                accountNumber: account.accountNumber,
                accountBaseCurrency: account.accountBaseCurrency,
                balance: nil,
                fxBalance: nil,
                positions: [],
                orderCapabilities: account.orderCapabilities as? [TradeItInstrumentOrderCapabilities] ?? [],
                isEnabled: accountEnabled
            )

            if let matchingExistingAccount = (self.accounts.filter { account in
                return account.accountNumber == linkedBrokerAccount.accountNumber
            }).first {
                linkedBrokerAccount.balance = matchingExistingAccount.balance
                linkedBrokerAccount.fxBalance = matchingExistingAccount.fxBalance
                linkedBrokerAccount.balanceLastUpdated = matchingExistingAccount.balanceLastUpdated
            }

            return linkedBrokerAccount
        }

        self.accounts = newLinkedBrokerAccounts
        self.accountsLastUpdated = Date()
    }
}
