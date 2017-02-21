import PromiseKit

@objc public class TradeItLinkedBrokerManager: NSObject {
    public var linkedBrokers: [TradeItLinkedBroker] = []
    public weak var oAuthDelegate: TradeItOAuthDelegate?
    var connector: TradeItConnector
    var sessionProvider: TradeItSessionProvider

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

    public func getOAuthLoginPopupUrl(withBroker broker: String,
                                      oAuthCallbackUrl: String,
                                      onSuccess: @escaping (_ oAuthLoginPopupUrl: String) -> Void,
                                      onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.connector.getOAuthLoginPopupUrlForMobile(withBroker: broker,
                                                      interAppAddressCallback: oAuthCallbackUrl) { tradeItResult in
            switch tradeItResult {
            case let oAuthLoginPopupUrlForMobileResult as TradeItOAuthLoginPopupUrlForMobileResult:
                guard let oAuthUrl = oAuthLoginPopupUrlForMobileResult.oAuthURL,
                    !oAuthUrl.isEmpty
                else {
                    onFailure(TradeItErrorResult(title: "Received empty OAuth login popup URL"))
                    return
                }

                onSuccess(oAuthLoginPopupUrlForMobileResult.oAuthURL ?? "")
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult(title: "Failed to retrieve OAuth login popup URL"))
            }
        }
    }

    public func getOAuthLoginPopupForTokenUpdateUrl(withBroker broker: String,
                                                    userId: String,
                                                    deepLinkCallback: String,
                                                    onSuccess: @escaping (_ oAuthLoginPopupUrl: String) -> Void,
                                                    onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.connector.getOAuthLoginPopupURLForTokenUpdate(withBroker: broker,
                                                           userId: userId,
                                                           interAppAddressCallback: deepLinkCallback) { tradeItResult in
            switch tradeItResult {
            case let oAuthLoginPopupUrlForTokenUpdateResult as TradeItOAuthLoginPopupUrlForTokenUpdateResult:
                onSuccess(oAuthLoginPopupUrlForTokenUpdateResult.oAuthURL ?? "")
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult(title: "Failed to retrieve OAuth login popup URL for token update"))
            }
        }
    }

    public func completeOAuth(withOAuthVerifier oAuthVerifier: String,
                              onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                              onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
        self.connector.getOAuthAccessToken(withOAuthVerifier: oAuthVerifier) { tradeItResult in
            switch tradeItResult {
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            case let oAuthAccessTokenResult as TradeItOAuthAccessTokenResult:
                guard let userId = oAuthAccessTokenResult.userId,
                    let userToken = oAuthAccessTokenResult.userToken
                else {
                    onFailure(TradeItErrorResult(
                        title: "OAuth Error",
                        message: "Failed to link broker, did not receive OAuth token")
                    )

                    return
                }

                if let linkedBroker = self.getLinkedBroker(forUserId: userId) {
                    // userId already exists, this is a relink
                    let linkedLogin = self.connector.updateKeychain(withLink: oAuthAccessTokenResult,
                                                                    withBroker: linkedBroker.linkedLogin.broker)
                    if let linkedLogin = linkedLogin {
                        linkedBroker.error = nil
                        linkedBroker.linkedLogin = linkedLogin

                        self.oAuthDelegate?.didLink?(linkedBroker: linkedBroker,
                                                     userId: userId,
                                                     userToken: userToken)
                        onSuccess(linkedBroker)
                    } else {
                        let error = TradeItErrorResult(title: "Keychain error",
                                                       message: "Failed to update linked login in the keychain")
                        linkedBroker.error = error
                        onFailure(error)
                    }
                } else {
                    guard let broker = oAuthAccessTokenResult.broker else {
                        let error = TradeItErrorResult(title: "Failed to complete OAuth",
                                                       message: "Service did not return a broker")
                        onFailure(error)
                        return
                    }

                    let linkedLogin = self.connector.saveToKeychain(withLink: oAuthAccessTokenResult,
                                                                    withBroker: broker)
                    if let linkedLogin = linkedLogin {
                        let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
                        self.linkedBrokers.append(linkedBroker)

                        self.oAuthDelegate?.didLink?(linkedBroker: linkedBroker,
                                                     userId: userId,
                                                     userToken: userToken)

                        onSuccess(linkedBroker)
                    } else {
                        onFailure(TradeItErrorResult(
                            title: "Keychain error",
                            message: "Failed to save the linked login to the device keychain"
                        ))
                    }
                }
            default:
                onFailure(TradeItErrorResult(
                    title: "OAuth Error",
                    message: "Could not complete OAuth"
                ))
            }
        }
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
                           onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                               _ submitAnswer: @escaping (String) -> Void,
                               _ onCancelSecurityQuestion: @escaping () -> Void
                           ) -> Void,
                           onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.connector.linkBroker(with: authInfo) { authResult in
            switch authResult {
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            case let authResult as TradeItAuthLinkResult:
                self.saveLinkedBrokerToKeychain(
                    userId: authResult.userId,
                    userToken: authResult.userToken,
                    broker: authInfo.broker,
                    onSuccess: onSuccess,
                    onSecurityQuestion: onSecurityQuestion,
                    onFailure: onFailure
                )
            default:
                onFailure(TradeItErrorResult(title: "Keychain error"))
            }

        }
    }

    public func linkBroker(userId: String,
                           userToken: String,
                           broker: String,
                           onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                           onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                                _ submitAnswer: @escaping (String) -> Void,
                                _ onCancelSecurityQuestion: @escaping () -> Void
                            ) -> Void,
                           onFailure: @escaping (TradeItErrorResult) -> Void) {
        saveLinkedBrokerToKeychain(userId: userId,
                                   userToken: userToken,
                                   broker: broker,
                                   onSuccess: onSuccess,
                                   onSecurityQuestion: onSecurityQuestion,
                                   onFailure: onFailure)
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
                      onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                        _ submitAnswer: @escaping (String) -> Void,
                        _ onCancelSecurityQuestion: @escaping () -> Void
                      ) -> Void,
                      onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
        self.connector.updateUserToken(linkedBroker.linkedLogin,
                                       authInfo: authInfo,
                                       andCompletionBlock: { result in
            switch result {
            case let errorResult as TradeItErrorResult:
                linkedBroker.error = errorResult
                onFailure(errorResult)
            case let updateLinkResult as TradeItUpdateLinkResult:
                guard let userId = updateLinkResult.userId,
                    let userToken = updateLinkResult.userToken
                else {
                    return onFailure(TradeItErrorResult(
                        title: "Linking Error",
                        message: "Failed to relink broker, did not receive token")
                    )
                }

                let linkedLogin = self.connector.updateKeychain(withLink: updateLinkResult,
                                                                withBroker: linkedBroker.linkedLogin.broker)

                if let linkedLogin = linkedLogin {
                    linkedBroker.error = nil
                    linkedBroker.linkedLogin = linkedLogin
                    linkedBroker.authenticate(
                        onSuccess: {
                            self.oAuthDelegate?.didLink?(linkedBroker: linkedBroker, userId: userId, userToken: userToken)
                            onSuccess(linkedBroker)
                        },
                        onSecurityQuestion: onSecurityQuestion,
                        onFailure: { error in
                            // Consider a success because linking succeeded. Just not able to authenticate after.
                            self.oAuthDelegate?.didLink?(linkedBroker: linkedBroker, userId: userId, userToken: userToken)
                            onSuccess(linkedBroker)
                        }
                    )
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
            self.oAuthDelegate?.didUnlink?(linkedBroker: linkedBroker)
        }
    }

    // MARK: Private

    private func getLinkedBroker(forUserId userId: String) -> TradeItLinkedBroker? {
        return self.linkedBrokers.filter({ $0.linkedLogin.userId == userId }).first
    }

    private func loadLinkedBrokersFromKeychain() {
        let linkedLoginsFromKeychain = self.connector.getLinkedLogins() as! [TradeItLinkedLogin]

        self.linkedBrokers = linkedLoginsFromKeychain.map { linkedLogin in
            let linkedBroker = loadLinkedBrokerFromLinkedLogin(linkedLogin)
            TradeItSDK.linkedBrokerCache.syncFromCache(linkedBroker: linkedBroker)
            return linkedBroker
        }
    }

    private func loadLinkedBrokerFromLinkedLogin(_ linkedLogin: TradeItLinkedLogin) -> TradeItLinkedBroker {
        let tradeItSession = sessionProvider.provide(connector: self.connector)
        //provides a default token, so if the user doesn't authenticate before an other call, it will pass an expired token in order to get the session expired error
        tradeItSession?.token = "dd61aa94fa094e6ab54fa4b31853bbd4"
        return TradeItLinkedBroker(session: tradeItSession!, linkedLogin: linkedLogin)
    }

    private func saveLinkedBrokerToKeychain(userId: String?,
                                            userToken: String?,
                                            broker: String,
                                            onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
                                            onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                                                _ submitAnswer: @escaping (String) -> Void,
                                                _ onCancelSecurityQuestion: @escaping () -> Void
                                            ) -> Void,
                                            onFailure: @escaping (TradeItErrorResult) -> Void) {
        let linkedLogin = self.connector.saveToKeychain(withUserId: userId, andUserToken: userToken, andBroker: broker, andLabel: broker)

        if let linkedLogin = linkedLogin, let userId = userId, let userToken = userToken {
            let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)

            linkedBroker.authenticateIfNeeded(
                onSuccess: {
                    self.linkedBrokers.append(linkedBroker)
                    self.oAuthDelegate?.didLink?(linkedBroker: linkedBroker, userId: userId, userToken: userToken)
                    onSuccess(linkedBroker)
                },
                onSecurityQuestion: onSecurityQuestion,
                onFailure: onFailure
            )
        } else {
            onFailure(TradeItErrorResult(
                title: "Keychain error",
                message: "Failed to save the linked login to the keychain"
            ))
        }
    }
}

@objc public protocol TradeItOAuthDelegate {
    @objc optional func didLink(linkedBroker: TradeItLinkedBroker, userId: String, userToken: String)
    @objc optional func didUnlink(linkedBroker: TradeItLinkedBroker)
}
