import PromiseKit

@objc public class TradeItLinkedBroker: NSObject {
    public var accountsLastUpdated: Date?
    public var accounts: [TradeItLinkedBrokerAccount] = []
    public var error: TradeItErrorResult?
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

    public func authenticate(onSuccess: @escaping () -> Void,
                             onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                                                            _ submitAnswer: @escaping (String) -> Void,
                                                            _ onCancelSecurityQuestion: @escaping () -> Void) -> Void,
                             onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
        let authenticationResponseHandler = YCombinator { handler in
            { (tradeItResult: TradeItResult) in
                switch tradeItResult {
                case let authenticationResult as TradeItAuthenticationResult:
                    self.error = nil

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
                            handler(TradeItErrorResult(
                                title: "Authentication failed",
                                message: "The security question was canceled.",
                                code: .sessionError
                            ))
                        }
                    )
                case let error as TradeItErrorResult:
                    self.error = error
                    onFailure(error)
                default:
                    handler(TradeItErrorResult(
                        title: "Authentication failed",
                        code: .sessionError
                    ))
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
        onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
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

    public func refreshAccountBalances(force: Bool = true,
                                       cacheResult: Bool = true,
                                       onFinished: @escaping () -> Void) {
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
    
    public func isAccountLinkDelayedError() -> Bool {
        guard let error = self.error else {
            return false
        }
        return error.isAccountLinkDelayedError()
    }

    // MARK: Private

    private func updateLinkedBrokerAccounts(fromBrokerAccounts accounts: [TradeItBrokerAccount]) {
        let newLinkedBrokerAccounts = accounts.map { account -> TradeItLinkedBrokerAccount in
            let accountEnabled = findAccount(byAccountNumber: account.accountNumber)?.isEnabled ?? true

            let linkedBrokerAccount = TradeItLinkedBrokerAccount(
                linkedBroker: self,
                accountName: account.name,
                accountNumber: account.accountNumber,
                balance: nil,
                fxBalance: nil,
                positions: [],
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
