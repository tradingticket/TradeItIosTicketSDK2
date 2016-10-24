import PromiseKit

@objc public class TradeItLinkedBrokerManager: NSObject {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider
    public var linkedBrokers: [TradeItLinkedBroker] = []
    
    public init(apiKey: String, environment: TradeitEmsEnvironments) {
        // TODO: TradeItConnector initializer returns optional - we should not force unwrap
        self.tradeItConnector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)!
        self.tradeItSessionProvider = TradeItSessionProvider()

        super.init()
        self.loadLinkedBrokersFromKeychain()
    }
    
    init(tradeItConnector: TradeItConnector) {
        self.tradeItConnector = tradeItConnector
        self.tradeItSessionProvider = TradeItSessionProvider()
        
        super.init()
        self.loadLinkedBrokersFromKeychain()
    }
    
    func loadLinkedBrokersFromKeychain() {
        let linkedLoginsFromKeychain = self.tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]

        self.linkedBrokers = linkedLoginsFromKeychain.map { linkedLogin in
            return loadLinkedBrokerFromLinkedLogin(linkedLogin)
        }
    }

    func loadLinkedBrokerFromLinkedLogin(linkedLogin: TradeItLinkedLogin) -> TradeItLinkedBroker {
        let tradeItSession = tradeItSessionProvider.provide(connector: self.tradeItConnector)
        let linkedBroker = TradeItLinkedBroker(session: tradeItSession, linkedLogin: linkedLogin)
        
        // Mark the linked broker as errored so that it will be authenticated next time authenticateAll is called
        linkedBroker.error = TradeItErrorResult(
            title: "Linked Broker initialized from keychain",
            message: "This linked broker needs to authenticate.",
            code: .SESSION_ERROR
        )

        return linkedBroker
    }

    public func authenticateAll(onSecurityQuestion onSecurityQuestion: (TradeItSecurityQuestionResult,
                                                                 submitAnswer: (String) -> Void,
                                                                 onCancelSecurityQuestion: () -> Void) -> Void,
                                            onFailure: (TradeItErrorResult, TradeItLinkedBroker) -> Void = {_ in },
                                            onFinished: () -> Void) {
        let promises = self.linkedBrokers.filter { $0.error != nil }.map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.authenticate(
                    onSuccess: fulfill,
                    onSecurityQuestion: onSecurityQuestion,
                    onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                        onFailure(tradeItErrorResult, linkedBroker)
                        fulfill()
                    }
                )
            }
        }

        when(promises).always(onFinished)
    }

    public func refreshAccountBalances(onFinished onFinished: () -> Void) {
        let promises = self.linkedBrokers.map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.refreshAccountBalances(onFinished: fulfill)
            }
        }

        when(promises).always(onFinished)
    }

    public func getAvailableBrokers(onSuccess onSuccess: (availableBrokers: [TradeItBroker]) -> Void,
                                       onFailure: () -> Void) {
        self.tradeItConnector.getAvailableBrokersWithCompletionBlock { (availableBrokers: [TradeItBroker]?) in
            if let availableBrokers = availableBrokers {
                onSuccess(availableBrokers: availableBrokers)
            } else {
                onFailure()
            }
        }
    }

    public func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                             onSuccess: (linkedBroker: TradeItLinkedBroker) -> Void,
                             onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.tradeItConnector.linkBrokerWithAuthenticationInfo(authInfo) { (tradeItResult: TradeItResult?) in
            switch tradeItResult {
            case let tradeItErrorResult as TradeItErrorResult:
                onFailure(tradeItErrorResult)
            case let tradeItAuthResult as TradeItAuthLinkResult:
                let broker = authInfo.broker
                let linkedLogin = self.tradeItConnector.saveLinkToKeychain(tradeItAuthResult, withBroker: broker)
                
                if let linkedLogin = linkedLogin {
                    let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
                    self.linkedBrokers.append(linkedBroker)
                    onSuccess(linkedBroker: linkedBroker)
                } else {
                    onFailure(TradeItErrorResult(
                        title: "Keychain error",
                        message: "Failed to save the linked login to the keychain"
                    ))
                }
            default:
                onFailure(TradeItErrorResult(title: "Keychain error"))
            }
        }
    }

    func getAllAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.linkedBrokers.flatMap { $0.accounts }
    }
    
    func getAllEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.getAllAccounts().filter { $0.isEnabled }
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
                linkedBroker.error = errorResult
                onFailure(errorResult)
            case let updateLinkResult as TradeItUpdateLinkResult:
                let linkedLogin = self.tradeItConnector.updateLinkInKeychain(updateLinkResult, withBroker: linkedBroker.linkedLogin.broker)

                if let linkedLogin = linkedLogin {
                    linkedBroker.error = nil
                    linkedBroker.linkedLogin = linkedLogin
                    onSuccess(linkedBroker: linkedBroker)
                } else {
                    let error = TradeItErrorResult(title: "Keychain error", message: "Failed to update linked login in the keychain")
                    linkedBroker.error = error
                    onFailure(error)
                }
            default:
                let error = TradeItErrorResult(title: "Keychain error")
                linkedBroker.error = error
                onFailure(error)
            }
        })
    }

    func unlinkBroker(linkedBroker: TradeItLinkedBroker) {
        self.tradeItConnector.unlinkLogin(linkedBroker.linkedLogin)
        if let index = self.linkedBrokers.indexOf(linkedBroker) {
            self.linkedBrokers.removeAtIndex(index)
        }
    }
}
