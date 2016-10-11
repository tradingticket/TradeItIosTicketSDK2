import TradeItIosEmsApi
import PromiseKit

class TradeItLinkedBroker: NSObject {
    var session: TradeItSession
    var linkedLogin: TradeItLinkedLogin
    var accounts: [TradeItLinkedBrokerAccount] = []
    var isAuthenticated = false
    var error: TradeItErrorResult?

    init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        self.session = session
        self.linkedLogin = linkedLogin
    }

    func authenticate(onSuccess onSuccess: () -> Void,
                                onSecurityQuestion: (TradeItSecurityQuestionResult, (String) -> Void) -> Void,
                                onFailure: (TradeItErrorResult) -> Void) -> Void {
        let authenticationResponseHandler = YCombinator { handler in
            { (tradeItResult: TradeItResult!) in
                switch tradeItResult {
                case let authenticationResult as TradeItAuthenticationResult:
                    self.isAuthenticated = true
                    self.error = nil

                    let accounts = authenticationResult.accounts as! [TradeItBrokerAccount]
                    self.accounts = self.mapToLinkedBrokerAccounts(accounts)
                    onSuccess()
                case let securityQuestion as TradeItSecurityQuestionResult:
                    onSecurityQuestion(securityQuestion, { securityQuestionAnswer in
                        self.session.answerSecurityQuestion(securityQuestionAnswer, withCompletionBlock: handler)
                    })
                case let error as TradeItErrorResult:
                    self.isAuthenticated = false
                    self.error = error

                    onFailure(error)
                default:
                    handler(TradeItErrorResult.tradeErrorWithSystemMessage("Unknown respose sent from the server for authentication"))
                }

            }
        }
        self.session.authenticate(linkedLogin, withCompletionBlock: authenticationResponseHandler)
    }

    func refreshAccountBalances(onFinished onFinished: () -> Void) {
        let promises = accounts.map { account in
            return Promise<Void> { fulfill, reject in
                account.getAccountOverview(onSuccess: fulfill, onFailure: { errorResult in
                    print(errorResult)
                    fulfill()
                })
            }
        }

        when(promises).always(onFinished)
    }

    func getEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
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
