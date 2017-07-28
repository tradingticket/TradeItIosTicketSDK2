import PromiseKit

@objc public class TradeItLinkedBrokerManager: NSObject {
    private var connector: TradeItConnector
    private var sessionProvider: TradeItSessionProvider
    private var availableBrokersPromise: Promise<[TradeItBroker]>? = nil
    private var featuredBrokerLabelText: String?

    public var linkedBrokers: [TradeItLinkedBroker] = []
    public weak var oAuthDelegate: TradeItOAuthDelegate?
    
    public convenience init(apiKey: String, environment: TradeitEmsEnvironments) {
        let connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        self.init(connector: connector)
    }

    init(connector: TradeItConnector) {
        self.connector = connector

        self.sessionProvider = TradeItSessionProvider()

        super.init()

        self.availableBrokersPromise = getAvailableBrokersPromise()        
        self.loadLinkedBrokersFromKeychain()
    }

    public func getOAuthLoginPopupUrl(
        withBroker broker: String,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.getOAuthLoginPopupUrl(
            withBroker: broker,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }

    public func getOAuthLoginPopupUrl(
        withBroker broker: String,
        oAuthCallbackUrl: URL = TradeItSDK.oAuthCallbackUrl,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.connector.getOAuthLoginPopupUrlForMobile(
            withBroker: broker,
            oAuthCallbackUrl: oAuthCallbackUrl
        ) { tradeItResult in
            switch tradeItResult {
            case let oAuthLoginPopupUrlForMobileResult as TradeItOAuthLoginPopupUrlForMobileResult:
                guard let oAuthUrl = oAuthLoginPopupUrlForMobileResult.oAuthUrl() else {
                    onFailure(
                        TradeItErrorResult(
                            title: "Received empty OAuth login popup URL"
                        )
                    )
                    return
                }

                onSuccess(oAuthUrl)
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult(title: "Failed to retrieve OAuth login popup URL"))
            }
        }
    }

    public func getOAuthLoginPopupForTokenUpdateUrl(
        forLinkedBroker linkedBroker: TradeItLinkedBroker,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.getOAuthLoginPopupForTokenUpdateUrl(
            forLinkedBroker: linkedBroker,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }

    public func getOAuthLoginPopupForTokenUpdateUrl(
        forLinkedBroker linkedBroker: TradeItLinkedBroker,
        oAuthCallbackUrl: URL,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.getOAuthLoginPopupForTokenUpdateUrl(
            withBroker: linkedBroker.brokerName,
            userId: linkedBroker.linkedLogin.userId ?? "",
            oAuthCallbackUrl: oAuthCallbackUrl,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }

    public func completeOAuth(
        withOAuthVerifier oAuthVerifier: String,
        onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) -> Void {
        self.connector.getOAuthAccessToken(withOAuthVerifier: oAuthVerifier) { tradeItResult in
            switch tradeItResult {
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            case let oAuthAccessTokenResult as TradeItOAuthAccessTokenResult:
                let userId = oAuthAccessTokenResult.userId
                let userToken = oAuthAccessTokenResult.userToken

                if let linkedBroker = self.getLinkedBroker(forUserId: userId) {
                    // userId already exists, this is a relink
                    let linkedLogin = self.connector.updateKeychain(
                        withLink: oAuthAccessTokenResult,
                        withBroker: linkedBroker.brokerName
                    )

                    if let linkedLogin = linkedLogin {
                        linkedBroker.setUnauthenticated()
                        linkedBroker.linkedLogin = linkedLogin

                        self.oAuthDelegate?.didLink?(
                            userId: userId,
                            userToken: userToken)
                        onSuccess(linkedBroker)
                    } else {
                        let error = TradeItErrorResult(
                            title: "Keychain error",
                            message: "Failed to update linked login in the keychain"
                        )

                        linkedBroker.error = error
                        onFailure(error)
                    }
                } else {
                    guard let broker = oAuthAccessTokenResult.broker else {
                        let error = TradeItErrorResult(
                            title: "Failed to complete OAuth",
                            message: "Service did not return a broker"
                        )

                        onFailure(error)
                        return
                    }

                    let linkedLogin = self.connector.saveToKeychain(
                        withLink: oAuthAccessTokenResult,
                        withBroker: broker
                    )

                    if let linkedLogin = linkedLogin {
                        let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
                        self.linkedBrokers.append(linkedBroker)

                        self.oAuthDelegate?.didLink?(
                            userId: userId,
                            userToken: userToken
                        )

                        onSuccess(linkedBroker)
                    } else {
                        onFailure(
                            TradeItErrorResult(
                                title: "Keychain error",
                                message: "Failed to save the linked login to the device keychain"
                            )
                        )
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

    public func authenticateAll(
        onSecurityQuestion: @escaping (
            TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void
        ) -> Void,
        onFailure: @escaping (TradeItErrorResult, TradeItLinkedBroker) -> Void = {_ in },
        onFinished: @escaping () -> Void
    ) {
        let promises = self.getAllDisplayableLinkedBrokers().map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.authenticateIfNeeded(
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
    
    public func refreshAccountBalances(force: Bool = true, onFinished: @escaping () -> Void) {
        let promises = self.getAllAuthenticatedLinkedBrokers().map { linkedBroker in
            return Promise<Void> { fulfill, reject in
                linkedBroker.refreshAccountBalances(force: force, onFinished: fulfill)
            }
        }

        let _ = when(resolved: promises).always(execute: onFinished)
    }

    public func getAvailableBrokers(
        onSuccess: @escaping (_ availableBrokers: [TradeItBroker]) -> Void,
        onFailure: @escaping () -> Void
    ) {
        getAvailableBrokersPromise().then { availableBrokers -> Void in
            onSuccess(availableBrokers)
        }.catch { error in
            self.availableBrokersPromise = nil
            onFailure()
        }
    }

    public func injectBroker(
        userIdUserTokenBroker: UserIdUserTokenBroker,
        onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.saveLinkedBrokerToKeychain(
            userIdUserTokenBroker: userIdUserTokenBroker,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }

    public func getAllAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.linkedBrokers.flatMap { $0.accounts }
    }

    public func getAllEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.getAllAccounts().filter { $0.isEnabled }
    }
    
    public func getAllAuthenticatedAndEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.getAllAuthenticatedLinkedBrokers().flatMap { $0.accounts }.filter { $0.isEnabled }
    }

    public func getAllEnabledLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.getEnabledAccounts().count > 0}
    }
    
    public func getAllDisplayableLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.getEnabledAccounts().count > 0 || $0.isAccountLinkDelayedError}
    }
    
    public func getAllActivationInProgressLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter {$0.isAccountLinkDelayedError}
    }

    public func getAllLinkedBrokersInError() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error != nil }
    }

    public func getAllAuthenticatedLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error == nil }
    }

    public func unlinkBroker(
        _ linkedBroker: TradeItLinkedBroker,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.connector.unlinkLogin(linkedBroker.linkedLogin, localOnly: false) { result in
            switch result {
            case _ as TradeItUnlinkLoginResult:
                if let index = self.linkedBrokers.index(of: linkedBroker), let userId = linkedBroker.linkedLogin.userId {
                    TradeItSDK.linkedBrokerCache.remove(linkedBroker: linkedBroker)
                    self.linkedBrokers.remove(at: index)
                    self.oAuthDelegate?.didUnlink?(userId: userId)
                    NotificationCenter.default.post(
                        name: TradeItSDK.didUnlinkNotificationName,
                        object: nil,
                        userInfo: [
                            "linkedBroker": linkedBroker
                        ]
                    )
                }
                onSuccess()
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            default:
                onFailure(TradeItErrorResult(title: "Something went wrong trying to unlink. Please try again later."))
            }
        }
    }

    public func getLinkedBroker(forUserId userId: String?) -> TradeItLinkedBroker? {
        return self.linkedBrokers.filter({ $0.linkedLogin.userId == userId }).first
    }
    
    public func syncLocalLinkedBrokers(
        userIdUserTokenBrokerList: [UserIdUserTokenBroker],
        onFailure: @escaping (TradeItErrorResult) -> Void,
        onFinished: @escaping () -> Void
    ) {
        // Add missing linkedBrokers
        let userIdsFromlinkedBrokers = self.linkedBrokers.flatMap { $0.linkedLogin.userId }
        let userIdUserTokenBrokersToAdd = userIdUserTokenBrokerList.filter { !userIdsFromlinkedBrokers.contains($0.userId) }
        
        userIdUserTokenBrokersToAdd.forEach { userIdUserTokenBroker in
            injectBroker(
                userIdUserTokenBroker: userIdUserTokenBroker,
                onSuccess: { (linkedBroker) in
                    TradeItSDK.linkedBrokerCache.cache(linkedBroker: linkedBroker)
                },
                onFailure: onFailure
            )
        }
        
        // Remove non existing linkedBrokers
        let linkedBrokersToRemove = self.linkedBrokers.filter {
            !userIdUserTokenBrokerList.flatMap { $0.userId }.contains($0.linkedLogin.userId ?? "")
        }

        linkedBrokersToRemove.forEach { linkedBrokerToRemove in
            self.removeBroker(linkedBroker: linkedBrokerToRemove)
        }
        
        onFinished()
    }

    // MARK: Internal

    @available(*, deprecated, message: "See documentation for supporting oAuth flow.")
    internal func linkBroker(
        authInfo: TradeItAuthenticationInfo,
        onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
        onSecurityQuestion: @escaping (
            TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void
        ) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.connector.linkBroker(with: authInfo) { authResult in
            switch authResult {
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            case let authResult as TradeItAuthLinkResult:
                let userIdUserTokenBroker = UserIdUserTokenBroker(
                    userId: authResult.userId,
                    userToken: authResult.userToken,
                    broker: authInfo.broker
                )
                self.saveLinkedBrokerToKeychain(
                    userIdUserTokenBroker: userIdUserTokenBroker,
                    onSuccess: { linkedBroker in
                        linkedBroker.authenticateIfNeeded(
                            onSuccess: {
                                self.oAuthDelegate?.didLink?(
                                    userId: userIdUserTokenBroker.userId,
                                    userToken: userIdUserTokenBroker.userToken
                                )
                                onSuccess(linkedBroker)
                            },
                            onSecurityQuestion: onSecurityQuestion,
                            onFailure: onFailure
                        )
                    },
                    onFailure: onFailure
                )
            default:
                onFailure(TradeItErrorResult(title: "Keychain error"))
            }

        }
    }

    @available(*, deprecated, message: "See documentation for supporting oAuth flow.")
    internal func relinkBroker(
        _ linkedBroker: TradeItLinkedBroker,
        authInfo: TradeItAuthenticationInfo,
        onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
        onSecurityQuestion: @escaping (
            TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void
        ) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) -> Void {
        self.connector.updateUserToken(
            linkedBroker.linkedLogin,
            authInfo: authInfo,
            andCompletionBlock: { result in
                switch result {
                case let errorResult as TradeItErrorResult:
                    linkedBroker.error = errorResult
                    onFailure(errorResult)
                case let updateLinkResult as TradeItUpdateLinkResult:
                    let linkedLogin = self.connector.updateKeychain(
                        withLink: updateLinkResult,
                        withBroker: linkedBroker.brokerName
                    )

                    if let linkedLogin = linkedLogin {
                        linkedBroker.clearError()
                        linkedBroker.linkedLogin = linkedLogin
                        linkedBroker.authenticate(
                            onSuccess: {
                                self.oAuthDelegate?.didLink?(userId: updateLinkResult.userId, userToken: updateLinkResult.userToken)
                                onSuccess(linkedBroker)
                            },
                            onSecurityQuestion: onSecurityQuestion,
                            onFailure: { error in
                                // Consider a success because linking succeeded. Just not able to authenticate after.
                                self.oAuthDelegate?.didLink?(userId: updateLinkResult.userId, userToken: updateLinkResult.userToken)
                                onSuccess(linkedBroker)
                            }
                        )
                    } else {
                        let error = TradeItErrorResult(
                            title: "Keychain error",
                            message: "Failed to update linked login in the keychain"
                        )

                        linkedBroker.error = error
                        onFailure(error)
                    }
                default:
                    let error = TradeItErrorResult(title: "Keychain error")
                    linkedBroker.error = error
                    onFailure(error)
                }
            }
        )
    }

    // MARK: Private

    private func getOAuthLoginPopupForTokenUpdateUrl(
        withBroker broker: String? = nil,
        userId: String,
        oAuthCallbackUrl: URL = TradeItSDK.oAuthCallbackUrl,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        guard let brokerName = broker ?? self.getLinkedBroker(forUserId: userId)?.brokerName else {
            print("TradeItSDK ERROR: Could not determine broker name for getOAuthLoginPopupForTokenUpdateUrl()!")
            onFailure(
                TradeItErrorResult(
                    title: "Could not relink",
                    message: "Could not determine broker name for OAuth URL for relinking",
                    code: .systemError
                )
            )
            return
        }

        var relinkOAuthCallbackUrl = oAuthCallbackUrl

        if var urlComponents = URLComponents(
            url: oAuthCallbackUrl,
            resolvingAgainstBaseURL: false
        ) {
            urlComponents.addOrUpdateQueryStringValue(
                forKey: OAuthCallbackQueryParamKeys.relinkUserId.rawValue,
                value: userId
            )

            relinkOAuthCallbackUrl = urlComponents.url ?? oAuthCallbackUrl
        }

        self.connector.getOAuthLoginPopupURLForTokenUpdate(
            withBroker: brokerName,
            userId: userId,
            oAuthCallbackUrl: relinkOAuthCallbackUrl
        ) { tradeItResult in
            switch tradeItResult {
            case let oAuthLoginPopupUrlForTokenUpdateResult as TradeItOAuthLoginPopupUrlForTokenUpdateResult:
                guard let oAuthUrl = oAuthLoginPopupUrlForTokenUpdateResult.oAuthUrl() else {
                    onFailure(
                        TradeItErrorResult(
                            title: "Received empty OAuth token update popup URL"
                        )
                    )
                    return
                }

                onSuccess(oAuthUrl)
            case let errorResult as TradeItErrorResult:
                onFailure(errorResult)
            default:
                onFailure(
                    TradeItErrorResult(
                        title: "Failed to retrieve OAuth login popup URL for token update"
                    )
                )
            }
        }
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
        // provides a default token, so if the user doesn't authenticate before an other call, it will pass an expired token in order to get the session expired error
        tradeItSession.token = "trade-it-fetch-fresh-token"
        return TradeItLinkedBroker(session: tradeItSession, linkedLogin: linkedLogin)
    }

    private func saveLinkedBrokerToKeychain(
        userIdUserTokenBroker: UserIdUserTokenBroker,
        onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let linkedLogin = self.connector.saveToKeychain(
            withUserId: userIdUserTokenBroker.userId,
            andUserToken: userIdUserTokenBroker.userToken,
            andBroker: userIdUserTokenBroker.broker,
            andLabel: userIdUserTokenBroker.broker
        )

        if let linkedLogin = linkedLogin {
            let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
            if userIdUserTokenBroker.isAccountLinkDelayedError {
                linkedBroker.error = TradeItErrorResult(title: "Activation In Progress", message: "Your \(linkedBroker.brokerName) is being activated. Check back soon (up to two business days)", code: TradeItErrorCode.accountNotAvailable)
            }
            self.linkedBrokers.append(linkedBroker)
            onSuccess(linkedBroker)
        } else {
            onFailure(
                TradeItErrorResult(
                    title: "Keychain error",
                    message: "Failed to save the linked login to the keychain"
                )
            )
        }
    }
    
    private func getAvailableBrokersPromise() -> Promise<[TradeItBroker]> {
//        TODO: Add locking in case this gets called multiple times
//        let lockQueue = DispatchQueue(label: "getAvailableBrokersPromiseLock")
//        lockQueue.sync() { CODE GOES HERE }
        if let availableBrokersPromise = self.availableBrokersPromise {
            return availableBrokersPromise
        } else {
            let availableBrokersPromise = Promise<[TradeItBroker]> { fulfill, reject in
                self.connector.getAvailableBrokers(
                    withUserCountryCode: TradeItSDK.userCountryCode,
                    completionBlock: { (availableBrokers: [TradeItBroker]?, featuredBrokerLabelText: String?) in
                        if let featuredBrokerLabelText = featuredBrokerLabelText {
                            TradeItSDK.featuredBrokerLabelText = featuredBrokerLabelText
                        }

                        if let availableBrokers = availableBrokers {
                            self.featuredBrokerLabelText = featuredBrokerLabelText
                            fulfill(availableBrokers)
                        } else {
                            reject(
                                TradeItErrorResult(
                                    title: "Could not fetch brokers",
                                    message: "Could not fetch the brokers list. Please try again later."
                                )
                            )

                            self.availableBrokersPromise = nil
                        }
                    }
                )
            }

            self.availableBrokersPromise = availableBrokersPromise

            return availableBrokersPromise
        }
    }

    private func removeBroker(linkedBroker: TradeItLinkedBroker) {
        self.connector.unlinkLogin(linkedBroker.linkedLogin, localOnly: true) { result in
            if let index = self.linkedBrokers.index(of: linkedBroker) {
                TradeItSDK.linkedBrokerCache.remove(linkedBroker: linkedBroker)
                self.linkedBrokers.remove(at: index)
            }
        }
    }

    // MARK: Debugging

    internal func printLinkedBrokers() {
        print("\n\n=====> LINKED BROKERS:")

        self.linkedBrokers.forEach { linkedBroker in
            let linkedLogin = linkedBroker.linkedLogin
            let userToken = TradeItSDK.linkedBrokerManager.connector.userToken(fromKeychainId: linkedLogin.keychainId)

            print("=====> \(linkedBroker.brokerName)(\(linkedBroker.accounts.count) accounts)\n    accountsUpdated: \(String(describing: linkedBroker.accountsLastUpdated))\n    userId: \(linkedLogin.userId ?? "MISSING USER ID")\n    keychainId: \(linkedLogin.keychainId ?? "MISSING KEYCHAIN ID")\n    userToken: \(userToken ?? "MISSING USER TOKEN")\n    error: \(String(describing: linkedBroker.error?.errorCode)) - \(String(describing: linkedBroker.error?.shortMessage)) - \(String(describing: linkedBroker.error?.longMessages?.first))")

            print("        === ACCOUNTS ===")

            linkedBroker.accounts.forEach { account in
                print("        [\(account.accountNumber)][\(account.accountName)]")
                print("            balancesUpdated: \(String(describing: account.balanceLastUpdated)), buyingPower: \(String(describing: account.balance?.buyingPower))")
            }
        }

        print("=====> ===============\n\n")
    }
}

@objc public class UserIdUserTokenBroker: NSObject {
    let userId: String
    let userToken: String
    let broker: String
    let isAccountLinkDelayedError: Bool
    
    public init(
        userId: String,
        userToken: String,
        broker: String,
        isAccountLinkDelayedError: Bool = false
    ) {
        self.userId = userId
        self.userToken = userToken
        self.broker = broker
        self.isAccountLinkDelayedError = isAccountLinkDelayedError
    }
}


@objc public protocol TradeItOAuthDelegate {
    @objc optional func didLink(userId: String, userToken: String)
    @objc optional func didUnlink(userId: String)
}
