import PromiseKit

public class TradeItLinkedBroker: NSObject {
    var session: TradeItSession
    var linkedLogin: TradeItLinkedLogin
    public var accounts: [TradeItLinkedBrokerAccount] = []
    public var error: TradeItErrorResult?
    
    public init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        self.session = session
        self.linkedLogin = linkedLogin
    }

    public func authenticate(onSuccess onSuccess: () -> Void,
                                       onSecurityQuestion: (TradeItSecurityQuestionResult,
                                                            submitAnswer: (String) -> Void,
                                                            onCancelSecurityQuestion: () -> Void) -> Void,
                                       onFailure: (TradeItErrorResult) -> Void) -> Void {
        let authenticationResponseHandler = YCombinator { handler in
            { (tradeItResult: TradeItResult) in
                switch tradeItResult {
                case let authenticationResult as TradeItAuthenticationResult:
                    self.error = nil

                    let accounts = authenticationResult.accounts as! [TradeItBrokerAccount]
                    self.accounts = self.mapToLinkedBrokerAccounts(accounts)
                    onSuccess()
                case let securityQuestion as TradeItSecurityQuestionResult:
                    onSecurityQuestion(
                        securityQuestion,
                        submitAnswer: { securityQuestionAnswer in
                            self.session.answerSecurityQuestion(securityQuestionAnswer, withCompletionBlock: handler)
                        },
                        onCancelSecurityQuestion: {
                            handler(TradeItErrorResult(
                                title: "Authentication failed",
                                message: "The security question was canceled.",
                                code: .BROKER_AUTHENTICATION_ERROR
                            ))
                        }
                    )
                case let error as TradeItErrorResult:
                    self.error = error
                    onFailure(error)
                default:
                    handler(TradeItErrorResult.tradeErrorWithSystemMessage("Unknown response sent from the server for authentication."))
                }
            }
        }

        self.session.authenticate(linkedLogin, withCompletionBlock: authenticationResponseHandler)
    }

    public func refreshAccountBalances(onFinished onFinished: () -> Void) {
        let promises = accounts.map { account in
            return Promise<Void> { fulfill, reject in
                account.getAccountOverview(onSuccess: fulfill, onFailure: { errorResult in
                    fulfill()
                })
            }
        }

        when(promises).always(onFinished)
    }

    public func getEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.accounts.filter { return $0.isEnabled }
    }

    private func mapToLinkedBrokerAccounts(accounts: [TradeItBrokerAccount]) -> [TradeItLinkedBrokerAccount] {
        return accounts.map { account in
            return TradeItLinkedBrokerAccount(
                linkedBroker: self,
                brokerName: self.linkedLogin.broker,
                accountName: account.name,
                accountNumber: account.accountNumber,
                balance: nil,
                fxBalance: nil,
                positions: []
            )
        }
    }
}
