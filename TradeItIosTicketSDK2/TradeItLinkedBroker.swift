import PromiseKit

@objc public class TradeItLinkedBroker: NSObject {
    public var accountsLastUpdated: Date?
    public var accounts: [TradeItLinkedBrokerAccount] = []
    public var error: TradeItErrorResult?
    var session: TradeItSession
    var linkedLogin: TradeItLinkedLogin
    private var linkedBrokerCache = TradeItLinkedBrokerCache()


    public var brokerName: String {
        return self.linkedLogin.broker ?? ""
    }

    public init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        self.session = session
        self.linkedLogin = linkedLogin
        // Mark the linked broker as errored so that it will be authenticated next time authenticateAll is called
        self.error = TradeItErrorResult(
                title: "Linked Broker initialized from keychain",
                message: "This linked broker needs to authenticate.",
                code: .sessionError
        )
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
                    self.accounts = self.mapToLinkedBrokerAccounts(accounts)

                    self.accountsLastUpdated = Date()

                    self.linkedBrokerCache.cache(linkedBroker: self)

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
                                code: .brokerAuthenticationError
                            ))
                        }
                    )
                case let error as TradeItErrorResult:
                    self.error = error
                    onFailure(error)
                default:
                    handler(TradeItErrorResult(
                        title: "Authentication failed",
                        code: .brokerAuthenticationError
                    ))
                }
            }
        }

        self.session.authenticate(linkedLogin, withCompletionBlock: authenticationResponseHandler)
    }
    
    public func authenticateIfNeeded(
        onSuccess: @escaping () -> Void,
        onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
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
        } else {
            onSuccess()
        }
    }

    public func refreshAccountBalances(onFinished: @escaping () -> Void) {
        let promises = accounts.map { account in
            return Promise<Void> { fulfill, reject in
                account.getAccountOverview(onSuccess: fulfill, onFailure: { errorResult in
                    fulfill()
                })
            }
        }

        _ = when(resolved: promises).always(execute: onFinished)
    }

    public func getEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.accounts.filter { return $0.isEnabled }
    }

    private func mapToLinkedBrokerAccounts(_ accounts: [TradeItBrokerAccount]) -> [TradeItLinkedBrokerAccount] {
        return accounts.map { account in
            return TradeItLinkedBrokerAccount(
                linkedBroker: self,
                accountName: account.name,
                accountNumber: account.accountNumber,
                balance: nil,
                fxBalance: nil,
                positions: []
            )
        }
    }
}
