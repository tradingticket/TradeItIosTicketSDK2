import PromiseKit

@objc public class TradeItLinkedBrokerManager: NSObject {
    public var linkedBrokers: [TradeItLinkedBroker] = []
    public var authenticationDelegate: TradeItAuthenticationDelegate?
    var connector: TradeItConnector
    var sessionProvider: TradeItSessionProvider
    private var linkedBrokerCache = TradeItLinkedBrokerCache()

    public init(apiKey: String, environment: TradeitEmsEnvironments) {
        self.connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        self.sessionProvider = TradeItSessionProvider()

        super.init()
        self.loadLinkedBrokersFromKeychain()
    }

    init(connector: TradeItConnector) {
        self.connector = connector
        self.sessionProvider = TradeItSessionProvider()

        super.init()
        self.loadLinkedBrokersFromKeychain()
    }

    public func authenticateAll(onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                                                                 _ submitAnswer: @escaping (String) -> Void,
                                                                 _ onCancelSecurityQuestion: @escaping () -> Void) -> Void,
                                            onFailure: @escaping (TradeItErrorResult, TradeItLinkedBroker) -> Void = {_ in },
                                            onFinished: @escaping () -> Void) {
        let promises = self.getAllLinkedBrokersInError().map { linkedBroker in
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

        _ = when(resolved: promises).always(execute: onFinished)
    }

    public func refreshAccountBalances(onFinished: @escaping () -> Void) {
        let promises = self.linkedBrokers.map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.refreshAccountBalances(onFinished: fulfill)
            }
        }

        let _ = when(resolved: promises).always(execute: onFinished)
    }

    public func getAvailableBrokers(onSuccess: @escaping (_ availableBrokers: [TradeItBroker]) -> Void,
                                       onFailure: @escaping () -> Void) {
        self.connector.getAvailableBrokers { (availableBrokers: [TradeItBroker]?) in
            if let availableBrokers = availableBrokers {
                onSuccess(availableBrokers)
            } else {
                onFailure()
            }
        }
    }

    public func linkBroker(authInfo: TradeItAuthenticationInfo,
                           onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                           onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.connector.linkBroker(with: authInfo) { authResult in
            switch authResult {
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            case let authResult as TradeItAuthLinkResult:
                self.saveLinkedBrokerToKeychain(userId: authResult.userId, userToken: authResult.userToken, broker: authInfo.broker, onSuccess: onSuccess, onFailure: onFailure)
            default:
                onFailure(TradeItErrorResult(title: "Keychain error"))
            }

        }
    }

    public func linkBroker(userId: String,
                           userToken: String,
                           broker: String,
                           onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                           onFailure: @escaping (TradeItErrorResult) -> Void) {
        saveLinkedBrokerToKeychain(userId: userId, userToken: userToken, broker: broker, onSuccess: onSuccess, onFailure: onFailure)
    }

    public func getAllAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.linkedBrokers.flatMap { $0.accounts }
    }

    public func getAllEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.getAllAccounts().filter { $0.isEnabled }
    }

    public func getAllEnabledLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.getEnabledAccounts().count > 0}
    }

    public func getAllLinkedBrokersInError() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error != nil }
    }

    public func getAllAuthenticatedLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error == nil }
    }

    public func relinkBroker(_ linkedBroker: TradeItLinkedBroker, authInfo: TradeItAuthenticationInfo,
                      onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                      onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
        self.connector.updateUserToken(linkedBroker.linkedLogin, authInfo: authInfo, andCompletionBlock: { result in
            switch result {
            case let errorResult as TradeItErrorResult:
                linkedBroker.error = errorResult
                onFailure(errorResult)
            case let updateLinkResult as TradeItUpdateLinkResult:
                let linkedLogin = self.connector.updateKeychain(withLink: updateLinkResult, withBroker: linkedBroker.linkedLogin.broker)

                if let linkedLogin = linkedLogin {
                    linkedBroker.error = nil
                    linkedBroker.linkedLogin = linkedLogin
                    if let userId = updateLinkResult.userId, let userToken = updateLinkResult.userToken {
                        self.authenticationDelegate?.didLink(linkedBroker: linkedBroker, userId: userId, userToken: userToken)
                    }
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

    public func unlinkBroker(_ linkedBroker: TradeItLinkedBroker) {
        self.connector.unlinkLogin(linkedBroker.linkedLogin)
        if let index = self.linkedBrokers.index(of: linkedBroker) {
            self.linkedBrokers.remove(at: index)
            self.authenticationDelegate?.didUnlink(linkedBroker: linkedBroker)
        }
    }


    private func loadLinkedBrokersFromKeychain() {
        let linkedLoginsFromKeychain = self.connector.getLinkedLogins() as! [TradeItLinkedLogin]

        self.linkedBrokers = linkedLoginsFromKeychain.map { linkedLogin in
            let linkedBroker = loadLinkedBrokerFromLinkedLogin(linkedLogin)
            self.linkedBrokerCache.syncFromCache(linkedBroker: linkedBroker)
            return linkedBroker
        }
    }

    private func loadLinkedBrokerFromLinkedLogin(_ linkedLogin: TradeItLinkedLogin) -> TradeItLinkedBroker {
        let tradeItSession = sessionProvider.provide(connector: self.connector)
        return TradeItLinkedBroker(session: tradeItSession!, linkedLogin: linkedLogin)
    }

    private func saveLinkedBrokerToKeychain(userId: String?,
                                            userToken: String?,
                                            broker: String,
                                            onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                                            onFailure: @escaping (TradeItErrorResult) -> Void) {
        let linkedLogin = self.connector.saveToKeychain(withUserId: userId, andUserToken: userToken, andBroker: broker, andLabel: broker)

        if let linkedLogin = linkedLogin, let userId = userId, let userToken = userToken {
            let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
            self.linkedBrokers.append(linkedBroker)
            self.authenticationDelegate?.didLink(linkedBroker: linkedBroker, userId: userId, userToken: userToken)
            onSuccess(linkedBroker)
        } else {
            onFailure(TradeItErrorResult(
                title: "Keychain error",
                message: "Failed to save the linked login to the keychain"
            ))
        }
    }
}

@objc public protocol TradeItAuthenticationDelegate {
    func didLink(linkedBroker: TradeItLinkedBroker, userId: String, userToken: String)
    func didUnlink(linkedBroker: TradeItLinkedBroker)
}
