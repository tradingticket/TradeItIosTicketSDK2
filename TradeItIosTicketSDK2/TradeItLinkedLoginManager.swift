import TradeItIosEmsApi

class TradeItLinkedLoginManager {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider

//    var linkedBrokerAccounts: [TradeItLinkedAccountPortfolio] = []
//    var selectedBrokerAccountIndex = -1
//    
//    func getSelectedBrokerAccount() -> TradeItLinkedAccountPortfolio! {
//        var selecteBrokerAccount: TradeItLinkedAccountPortfolio! = nil
//        if selectedBrokerAccountIndex > -1 && linkedBrokerAccounts.count > 0 {
//            selecteBrokerAccount = linkedBrokerAccounts[selectedBrokerAccountIndex]
//        }
//        return selecteBrokerAccount
//    }

    init(connector connector: TradeItConnector) {
        tradeItConnector = connector
        tradeItSessionProvider = TradeItSessionProvider()
    }

    func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                             onSuccess: () -> Void,
                             onSecurityQuestion: (TradeItSecurityQuestionResult) -> String,
                             onFailure: (TradeItErrorResult) -> Void) -> Void {

        self.tradeItConnector.linkBrokerWithAuthenticationInfo(authInfo, andCompletionBlock: { (tradeItResult: TradeItResult?) in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                onFailure(tradeItErrorResult)
            } else if let tradeItResult = tradeItResult as? TradeItAuthLinkResult {
                let broker = authInfo.broker
                let linkedLogin = self.tradeItConnector.saveLinkToKeychain(tradeItResult,
                                                                            withBroker: broker)


                let tradeItSession = self.tradeItSessionProvider.provide(connector: self.tradeItConnector)

                tradeItSession.authenticate(linkedLogin,
                    withCompletionBlock: { (tradeItResult: TradeItResult!) in
                        if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                            onFailure(tradeItErrorResult)
                        } else if let tradeItSecurityQuestionResult = tradeItResult as? TradeItSecurityQuestionResult {
                            let securityQuestionAnswer = onSecurityQuestion(tradeItSecurityQuestionResult)
                            // TODO: submit security question answer
                        } else if let tradeItResult = tradeItResult as? TradeItAuthenticationResult {
//                            let accounts = tradeItResult.accounts as! [TradeItBrokerAccount]
                            onSuccess()
                        }
                })
            }
        })
    }


}