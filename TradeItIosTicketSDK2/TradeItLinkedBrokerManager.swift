import PromiseKit

@objc open class TradeItLinkedBrokerManager: NSObject {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider
    private var linkedBrokerCache = TradeItLinkedBrokerCache()
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
            let linkedBroker = loadLinkedBrokerFromLinkedLogin(linkedLogin)
            self.linkedBrokerCache.syncFromCache(linkedBroker: linkedBroker)
            return linkedBroker
        }
    }

    func loadLinkedBrokerFromLinkedLogin(_ linkedLogin: TradeItLinkedLogin) -> TradeItLinkedBroker {
        let tradeItSession = tradeItSessionProvider.provide(connector: self.tradeItConnector)
        return TradeItLinkedBroker(session: tradeItSession!, linkedLogin: linkedLogin)
    }

    open func authenticateAll(onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                                                                 _ submitAnswer: @escaping (String) -> Void,
                                                                 _ onCancelSecurityQuestion: @escaping () -> Void) -> Void,
                                            onFailure: @escaping (TradeItErrorResult, TradeItLinkedBroker) -> Void = {_ in },
                                            onFinished: @escaping () -> Void) {
        let promises = self.linkedBrokers.filter { $0.error != nil }.map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.authenticate(
                    onSuccess: fulfill,
                    onSecurityQuestion: onSecurityQuestion,
                    onFailure: { tradeItErrorResult in
                        onFailure(tradeItErrorResult, linkedBroker)
                        fulfill()
                    }
                )
            }
        }

        let _ = when(resolved: promises).always(execute: onFinished)
    }

    open func refreshAccountBalances(onFinished: @escaping () -> Void) {
        let promises = self.linkedBrokers.map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.refreshAccountBalances(onFinished: fulfill)
            }
        }

        let _ = when(resolved: promises).always(execute: onFinished)
    }

    open func getAvailableBrokers(onSuccess: @escaping (_ availableBrokers: [TradeItBroker]) -> Void,
                                       onFailure: @escaping () -> Void) {
        self.tradeItConnector.getAvailableBrokers { (availableBrokers: [TradeItBroker]?) in
            if let availableBrokers = availableBrokers {
                onSuccess(availableBrokers)
            } else {
                onFailure()
            }
        }
    }

    open func linkBroker(authInfo: TradeItAuthenticationInfo,
                             onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                             onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
        self.tradeItConnector.linkBroker(with: authInfo) { tradeItResult in
            switch tradeItResult {
            case let tradeItErrorResult as TradeItErrorResult:
                onFailure(tradeItErrorResult)
            case let tradeItAuthResult as TradeItAuthLinkResult:
                let broker = authInfo.broker
                let linkedLogin = self.tradeItConnector.saveToKeychain(withLink: tradeItAuthResult, withBroker: broker)

                if let linkedLogin = linkedLogin {
                    let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
                    self.linkedBrokers.append(linkedBroker)
                    onSuccess(linkedBroker)
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

    func getAllAuthenticatedLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error == nil }
    }
    
    func relinkBroker(_ linkedBroker: TradeItLinkedBroker, authInfo: TradeItAuthenticationInfo,
                      onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                      onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
        self.tradeItConnector.updateUserToken(linkedBroker.linkedLogin, authInfo: authInfo, andCompletionBlock: { tradeItResult in
            switch tradeItResult {
            case let errorResult as TradeItErrorResult:
                linkedBroker.error = errorResult
                onFailure(errorResult)
            case let updateLinkResult as TradeItUpdateLinkResult:
                let linkedLogin = self.tradeItConnector.updateKeychain(withLink: updateLinkResult, withBroker: linkedBroker.linkedLogin.broker)

                if let linkedLogin = linkedLogin {
                    linkedBroker.error = nil
                    linkedBroker.linkedLogin = linkedLogin
                    onSuccess(linkedBroker)
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

    func unlinkBroker(_ linkedBroker: TradeItLinkedBroker) {
        self.tradeItConnector.unlinkLogin(linkedBroker.linkedLogin)
        if let index = self.linkedBrokers.index(of: linkedBroker) {
            self.linkedBrokers.remove(at: index)
        }
    }
}
