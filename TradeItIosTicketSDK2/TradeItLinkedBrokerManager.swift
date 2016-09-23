import TradeItIosEmsApi
import PromiseKit

class TradeItLinkedBrokerManager {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider
    var linkedBrokers: [TradeItLinkedBroker] = []

    init(connector: TradeItConnector) {
        tradeItConnector = connector
        tradeItSessionProvider = TradeItSessionProvider()

        self.loadLinkedBrokersFromKeychain()
    }
    
    func loadLinkedBrokersFromKeychain() {
        let linkedLoginsFromKeychain = self.tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]
        for linkedLogin in linkedLoginsFromKeychain { loadLinkedBrokerFromLinkedLogin(linkedLogin) }
    }

    func loadLinkedBrokerFromLinkedLogin(linkedLogin: TradeItLinkedLogin) -> TradeItLinkedBroker {
        let tradeItSession = tradeItSessionProvider.provide(connector: self.tradeItConnector)
        let linkedBroker = TradeItLinkedBroker(session: tradeItSession, linkedLogin: linkedLogin)
        self.linkedBrokers.append(linkedBroker)
        return linkedBroker
    }

    func authenticateAll(onSecurityQuestion onSecurityQuestion: (TradeItSecurityQuestionResult) -> String,
                                            onFinished: () -> Void) {
        firstly { _ -> Promise<Void> in
            var promises: [Promise<Void>] = []

            for linkedBroker in self.linkedBrokers {
                let promise = Promise<Void> { fulfill, reject in
                    if !linkedBroker.isAuthenticated {
                        linkedBroker.authenticate(
                            onSuccess: { () -> Void in
                                fulfill()
                            },
                            onSecurityQuestion: { (tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String in
                                return onSecurityQuestion(tradeItSecurityQuestionResult)
                            },
                            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                                fulfill()
                            }
                        )
                    }
                    else {
                        fulfill()
                    }
                }

                promises.append(promise)
            }

            return when(promises)
        }
        .always() {
            onFinished()
        }
    }

    func refreshAccountBalances(onFinished onFinished: () -> Void) {
        firstly { _ -> Promise<Void> in
            var promises: [Promise<Void>] = []
            for linkedBroker in self.linkedBrokers {
                    let promise = Promise<Void> { fulfill, reject in
                        if linkedBroker.isAuthenticated {
                            linkedBroker.refreshAccountBalances(
                                onFinished: {
                                    fulfill()
                                }
                            )
                        }
                        else {
                            fulfill()
                        }
                    }
                    promises.append(promise)
            }
            return when(promises)
        }
        .always() {
            onFinished()
        }
    }

    func getAvailableBrokers(onSuccess onSuccess: (availableBrokers: [TradeItBroker]) -> Void,
                                       onFailure: () -> Void) {
        self.tradeItConnector.getAvailableBrokersWithCompletionBlock { (availableBrokers: [TradeItBroker]?) in
            if let availableBrokers = availableBrokers {
                onSuccess(availableBrokers: availableBrokers)
            } else {
                onFailure()
            }
        }
    }

    func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                             onSuccess: (linkedBroker: TradeItLinkedBroker) -> Void,
                             onFailure: (TradeItErrorResult) -> Void) -> Void {

        self.tradeItConnector.linkBrokerWithAuthenticationInfo(authInfo) { (tradeItResult: TradeItResult?) in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                onFailure(tradeItErrorResult)
            } else if let tradeItResult = tradeItResult as? TradeItAuthLinkResult {
                let broker = authInfo.broker
                let linkedLogin = self.tradeItConnector.saveLinkToKeychain(tradeItResult, withBroker: broker)
                if let linkedLogin = linkedLogin {
                    let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
                    onSuccess(linkedBroker: linkedBroker)
                } else {
                    let errorResult = TradeItErrorResult()
                    errorResult.systemMessage = "Failed to save linked login to keychain"
                    onFailure(errorResult)
                }
            }
        }
    }

    func getAllAccounts() -> [TradeItLinkedBrokerAccount] {
        var accounts: [TradeItLinkedBrokerAccount] = []

        for linkedBroker in self.linkedBrokers {
            accounts.appendContentsOf(linkedBroker.accounts)
        }

        return accounts
    }
    
    func getAllEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        var accounts: [TradeItLinkedBrokerAccount] = []
        
        for linkedBroker in self.linkedBrokers {
            accounts.appendContentsOf(linkedBroker.accounts.filter{ return $0.isEnabled == true})
        }
        
        return accounts
    }
    
    func relinkBroker(linkedBroker: TradeItLinkedBroker, authInfo: TradeItAuthenticationInfo,
                      onSuccess: (linkedBroker: TradeItLinkedBroker) -> Void,
                      onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.tradeItConnector.updateUserToken(linkedBroker.linkedLogin, withAuthenticationInfo: authInfo,
                                              andCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                onFailure(tradeItErrorResult)
            }
            else if let tradeItResult = tradeItResult as? TradeItUpdateLinkResult {
                let linkedLogin = self.tradeItConnector.updateLinkInKeychain(tradeItResult, withBroker: linkedBroker.linkedLogin.broker)
                if let linkedLogin = linkedLogin {
                    linkedBroker.linkedLogin = linkedLogin
                    onSuccess(linkedBroker: linkedBroker)
                } else {
                    let errorResult = TradeItErrorResult()
                    errorResult.systemMessage = "Failed to update linked login to keychain"
                    onFailure(errorResult)
                }
            }
        })
    }
    
    func unlinkBroker(linkedBroker: TradeItLinkedBroker) {
        self.tradeItConnector.unlinkLogin(linkedBroker.linkedLogin)
        let index = self.linkedBrokers.indexOf(linkedBroker)
        self.linkedBrokers.removeAtIndex(index!)
    }
}
