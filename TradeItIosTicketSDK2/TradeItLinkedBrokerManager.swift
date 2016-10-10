import TradeItIosEmsApi
import PromiseKit

class TradeItLinkedBrokerManager {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider
    var linkedBrokers: [TradeItLinkedBroker] = []

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        // TODO: TradeItConnector initializer returns optional - we should not force unwrap
        tradeItConnector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)!
        tradeItSessionProvider = TradeItSessionProvider()

        self.loadLinkedBrokersFromKeychain()
    }
    
    func loadLinkedBrokersFromKeychain() {
        let linkedLoginsFromKeychain = self.tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]

        for linkedLogin in linkedLoginsFromKeychain {
            loadLinkedBrokerFromLinkedLogin(linkedLogin)
        }
    }

    func loadLinkedBrokerFromLinkedLogin(linkedLogin: TradeItLinkedLogin) -> TradeItLinkedBroker {
        let tradeItSession = tradeItSessionProvider.provide(connector: self.tradeItConnector)
        let linkedBroker = TradeItLinkedBroker(session: tradeItSession, linkedLogin: linkedLogin)
        self.linkedBrokers.append(linkedBroker)

        return linkedBroker
    }

    func authenticateAll(onSecurityQuestion onSecurityQuestion: (TradeItSecurityQuestionResult, (String) -> Void) -> Void,
                                            onFinished: () -> Void) {
        let promises = self.linkedBrokers.filter { !$0.isAuthenticated }.map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.authenticate(
                    onSuccess: fulfill,
                    onSecurityQuestion: onSecurityQuestion,
                    onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                        fulfill()
                    }
                )
            }
        }

        when(promises).always(onFinished)
    }

    func refreshAccountBalances(onFinished onFinished: () -> Void) {
        let promises = self.linkedBrokers.filter { $0.isAuthenticated }.map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.refreshAccountBalances(onFinished: fulfill)
            }
        }

        when(promises).always(onFinished)
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
        return self.linkedBrokers.flatMap { $0.accounts }
    }
    
    func getAllEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return getAllAccounts().filter { $0.isEnabled }
    }
    
    func getAllEnabledLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.getEnabledAccounts().count > 0}
    }
    
    func getAllLinkedBrokersInError() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error != nil }
    }
    
    func relinkBroker(linkedBroker: TradeItLinkedBroker, authInfo: TradeItAuthenticationInfo,
                      onSuccess: (linkedBroker: TradeItLinkedBroker) -> Void,
                      onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.tradeItConnector.updateUserToken(linkedBroker.linkedLogin, withAuthenticationInfo: authInfo, andCompletionBlock: { tradeItResult in
            switch tradeItResult {
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            case let updateLinkResult as TradeItUpdateLinkResult:
                let linkedLogin = self.tradeItConnector.updateLinkInKeychain(updateLinkResult, withBroker: linkedBroker.linkedLogin.broker)

                if let linkedLogin = linkedLogin {
                    linkedBroker.linkedLogin = linkedLogin
                    onSuccess(linkedBroker: linkedBroker)
                } else {
                    onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Failed to update linked login to keychain"))
                }
            default:
                onFailure(TradeItErrorResult.tradeErrorWithSystemMessage("Failed to update user token"))
            }
        })
    }

    func unlinkBroker(linkedBroker: TradeItLinkedBroker) {
        self.tradeItConnector.unlinkLogin(linkedBroker.linkedLogin)
        let index = self.linkedBrokers.indexOf(linkedBroker)
        self.linkedBrokers.removeAtIndex(index!)
    }
}
