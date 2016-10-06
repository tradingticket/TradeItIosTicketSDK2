import TradeItIosEmsApi
import PromiseKit

class TradeItLinkedBroker: NSObject {
    var session: TradeItSession
    var linkedLogin: TradeItLinkedLogin
    var accounts: [TradeItLinkedBrokerAccount] = []
    var isAuthenticated = false
    var error: TradeItErrorResult?
    var tradeService: TradeItTradeService

    init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        self.session = session
        self.linkedLogin = linkedLogin
        self.tradeService = TradeItTradeService(session: session)
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
                account.getAccountOverview(onFinished: fulfill)
            }
        }

        when(promises).always(onFinished)
    }

    func getEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.accounts.filter { return $0.isEnabled }
    }

    func getOrderPreview(order order: TradeItOrder,
                               onSuccess: (TradeItPreviewTradeResult) -> Void,
                               onFailure: (TradeItErrorResult) -> Void
                               ) -> Void {
        guard let orderPresenter = TradeItOrderPresenter(order: order) else { return }
        tradeService.previewTrade(orderPresenter.generateRequest(), withCompletionBlock: { result in
            switch result {
            case let previewOrderResult as TradeItPreviewTradeResult: onSuccess(previewOrderResult)
            case let errorResult as TradeItErrorResult: onFailure(errorResult)
            default: onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Error fetching preview."))
            }
        })
    }

    /*
    tradeService = [[TradeItTradeService alloc] initWithSession: self];
    [tradeService previewTrade:previewRequest withCompletionBlock:^(TradeItResult * res) {
    if ([res isKindOfClass:TradeItErrorResult.class]) {
      TradeItErrorResult * error = (TradeItErrorResult *)res;

      if ([error.code isEqualToNumber:@600]) {
        self.needsAuthentication = YES;
      } else if ([error.code isEqualToNumber:@700]) {
        self.needsManualAuthentication = YES;
      }

      completionBlock(res);
    } else {
      self.needsManualAuthentication = NO;
      self.needsAuthentication = NO;

      completionBlock(res);
    }
    }];*/

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
