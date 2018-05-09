import PromiseKit

@objc public class TradeItLinkedBrokerManager: NSObject {
    private var connector: TradeItConnector
    private var sessionProvider: TradeItSessionProvider
    private var availableBrokersPromise: Promise<[TradeItBroker]>? = nil
    private var featuredBrokerLabelText: String?
    private let brokerService: TradeItBrokerService
    private let oAuthService: TradeItOAuthService

    @objc public var linkedBrokers: [TradeItLinkedBroker] = []
    @objc public weak var oAuthDelegate: TradeItOAuthDelegate?

    init(connector: TradeItConnector) {
        self.connector = connector

        self.sessionProvider = TradeItSessionProvider()
        self.brokerService = TradeItBrokerService(connector: connector)
        self.oAuthService = TradeItOAuthService(connector: connector)
        
        super.init()

        self.availableBrokersPromise = getAvailableBrokersPromise()        
        self.loadLinkedBrokersFromKeychain()
    }

    @objc public func getOAuthLoginPopupUrl(
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

    @objc public func getOAuthLoginPopupUrl(
        withBroker broker: String,
        oAuthCallbackUrl: URL = TradeItSDK.oAuthCallbackUrl,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.oAuthService.getOAuthLoginPopupUrlForMobile(
            withBroker: broker,
            oAuthCallbackUrl: oAuthCallbackUrl,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }

    @objc public func getOAuthLoginPopupForTokenUpdateUrl(
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

    @objc public func getOAuthLoginPopupForTokenUpdateUrl(
        forLinkedBroker linkedBroker: TradeItLinkedBroker,
        oAuthCallbackUrl: URL,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.getOAuthLoginPopupForTokenUpdateUrl(
            withBroker: linkedBroker.brokerName,
            userId: linkedBroker.linkedLogin.userId,
            userToken: self.connector.userToken(fromKeychainId: linkedBroker.linkedLogin.keychainId) ?? "",
            oAuthCallbackUrl: oAuthCallbackUrl,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }

    @objc public func completeOAuth(
        withOAuthVerifier oAuthVerifier: String,
        onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) -> Void {
        self.oAuthService.getOAuthAccessToken(
            withOAuthVerifier: oAuthVerifier,
            onSuccess: { oAuthAccessTokenResult in
                let userId = oAuthAccessTokenResult.userId
                let userToken = oAuthAccessTokenResult.userToken
                
                if let linkedBroker = self.getLinkedBroker(forUserId: userId) {
                    // userId already exists, this is a relink
                    let linkedLogin = self.connector.updateKeychain(
                        withLink: oAuthAccessTokenResult,
                        withBroker: oAuthAccessTokenResult.broker,
                        withBrokerLongName: oAuthAccessTokenResult.brokerLongName
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
                            message: "Could not update linked broker on device. Please try again."
                        )
                        
                        linkedBroker.error = error
                        onFailure(error)
                    }
                } else {
                    guard let broker = oAuthAccessTokenResult.broker
                        , let brokerLongName = oAuthAccessTokenResult.brokerLongName else {
                        let error = TradeItErrorResult(
                            title: "Broker linking failed",
                            message: "Service did not return a broker. Please try again."
                        )
                        
                        onFailure(error)
                        return
                    }
                    
                    let linkedLogin = self.connector.saveToKeychain(
                        withLink: oAuthAccessTokenResult,
                        withBroker: broker,
                        withBrokerLongName: brokerLongName
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
                                message: "Could not save linked broker to device. Please try again."
                            )
                        )
                    }
                }
            },
            onFailure: onFailure
        )
    }

    @objc public func authenticateAll(
        onSecurityQuestion: @escaping (
            TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void
        ) -> Void,
        onFailure: @escaping (TradeItErrorResult, TradeItLinkedBroker) -> Void = {_,_  in },
        onFinished: @escaping () -> Void
    ) {
        let promises = self.getAllDisplayableLinkedBrokers().map { linkedBroker in
            return Promise<Void> { seal in
                linkedBroker.authenticateIfNeeded(
                    onSuccess: seal.fulfill,
                    onSecurityQuestion: onSecurityQuestion,
                    onFailure: { tradeItErrorResult in
                        onFailure(tradeItErrorResult, linkedBroker)
                        seal.fulfill(())
                    }
                )
            }
        }

        _ = when(resolved: promises).done { _ in onFinished() }
    }

    @objc public func refreshAccountBalances(force: Bool = true, onFinished: @escaping () -> Void) {
        let promises = self.getAllAuthenticatedLinkedBrokers().map { linkedBroker in
            return Promise<Void> { seal in
                linkedBroker.refreshAccountBalances(force: force, onFinished: seal.fulfill)
            }
        }

        let _ = when(resolved: promises).done { _ in onFinished() }
    }

    @objc public func getAvailableBrokers(
        onSuccess: @escaping (_ availableBrokers: [TradeItBroker]) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        getAvailableBrokersPromise().done(onSuccess).catch { error in
            self.availableBrokersPromise = nil
            let error = error as? TradeItErrorResult ??
                TradeItErrorResult(
                    title: "Could not fetch brokers",
                    message: "Could not fetch the brokers list. Please try again later."
                )
            onFailure(error)
        }
    }

    @objc public func getAllAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.linkedBrokers.flatMap { $0.accounts }
    }

    @objc public func getAllEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.getAllAccounts().filter { $0.isEnabled }
    }
    
    @objc public func getAllAuthenticatedAndEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return self.getAllAuthenticatedLinkedBrokers().flatMap { $0.accounts }.filter { $0.isEnabled }
    }

    @objc public func getAllEnabledLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.getEnabledAccounts().count > 0}
    }
    
    @objc public func getAllDisplayableLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.getEnabledAccounts().count > 0 || $0.isAccountLinkDelayedError}
    }
    
    @objc public func getAllActivationInProgressLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter {$0.isAccountLinkDelayedError}
    }

    @objc public func getAllLinkedBrokersInError() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error != nil }
    }

    @objc public func getAllAuthenticatedLinkedBrokers() -> [TradeItLinkedBroker] {
        return self.linkedBrokers.filter { $0.error == nil }
    }

    @objc public func unlinkBroker(
        _ linkedBroker: TradeItLinkedBroker,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.oAuthService.unlinkLogin(
            login: linkedBroker.linkedLogin,
            localOnly: false,
            onSuccess: { _ in
                if let index = self.linkedBrokers.index(of: linkedBroker) {
                    TradeItSDK.linkedBrokerCache.remove(linkedBroker: linkedBroker)
                    self.linkedBrokers.remove(at: index)

                    self.oAuthDelegate?.didUnlink?(userId: linkedBroker.linkedLogin.userId)
                    NotificationCenter.default.post(
                        name: TradeItNotification.Name.didUnlink,
                        object: nil,
                        userInfo: [
                            "linkedBroker": linkedBroker
                        ]
                    )
                }
                onSuccess()
            },
            onFailure: onFailure
        )
    }

    @objc public func getLinkedBroker(forUserId userId: String?) -> TradeItLinkedBroker? {
        return self.linkedBrokers.filter({ $0.linkedLogin.userId == userId }).first
    }
    
    @objc public func syncLocal(
        withRemoteLinkedBrokers remoteLinkedBrokers: [LinkedBrokerData],
        onFailure: @escaping (TradeItErrorResult) -> Void,
        onFinished: @escaping () -> Void
    ) {
        // Add missing linkedBrokers
        let localUserIds: [String] = self.linkedBrokers.compactMap { $0.linkedLogin.userId }
        let remoteLinkedBrokersToAdd = remoteLinkedBrokers.filter { !localUserIds.contains($0.userId) }

        remoteLinkedBrokersToAdd.forEach { remoteBrokerData in
            self.saveLinkedBrokerToKeychain(
                linkedBrokerData: remoteBrokerData,
                onSuccess: TradeItSDK.linkedBrokerCache.cache,
                onFailure: onFailure
            )
        }

        // Remove non existing linkedBrokers
        let remoteUserIds: [String] = remoteLinkedBrokers.compactMap { $0.userId }
        let linkedBrokersToRemove = self.linkedBrokers.filter {
            !remoteUserIds.contains($0.linkedLogin.userId)
        }

        linkedBrokersToRemove.forEach { linkedBrokerToRemove in
            self.removeBrokerLocally(linkedBroker: linkedBrokerToRemove)
        }

        // Sync accounts
        self.linkedBrokers.forEach { localLinkedBroker in
            remoteLinkedBrokers.first { remoteLinkedBroker in
                localLinkedBroker.linkedLogin.userId == remoteLinkedBroker.userId
            }.flatMap { remoteLinkedBroker in
                syncAccounts(localLinkedBroker: localLinkedBroker, remoteLinkedBroker: remoteLinkedBroker)
            }
        }

        onFinished()
    }

    // MARK: Internal
    internal func getBroker(
        shortName: String,
        onSuccess: @escaping (TradeItBroker) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.getAvailableBrokers(
            onSuccess: { brokers in
                guard let broker = brokers.first(
                    where: { broker in
                        return broker.shortName == shortName
                    }
                ) else {
                    onFailure(TradeItErrorResult.error(withSystemMessage: "This broker short name doesn't exist"))
                    return
                }
                onSuccess(broker)
            },
            onFailure:onFailure
        )
    }

    // MARK: Private

    private func syncAccounts(localLinkedBroker: TradeItLinkedBroker, remoteLinkedBroker: LinkedBrokerData) {
        // Add missing accounts
        let localAccountNumbers: [String] = localLinkedBroker.accounts.compactMap { $0.accountNumber }
        let remoteAccountsToAdd = remoteLinkedBroker.accounts.filter { !localAccountNumbers.contains($0.number) }

        remoteAccountsToAdd.forEach { remoteAccount in
            let account = TradeItLinkedBrokerAccount(linkedBroker: localLinkedBroker, accountData: remoteAccount)
            localLinkedBroker.accounts.append(account)
        }

        // Remove missing accounts
        let remoteAccountNumbers: [String] = remoteLinkedBroker.accounts.compactMap { $0.number }
        let localAccountsToRemove = localLinkedBroker.accounts.filter { !remoteAccountNumbers.contains($0.accountNumber) }

        localAccountsToRemove.forEach { localAccountToRemove in
            localLinkedBroker.accounts.remove(localAccountToRemove)
        }
    }

    private func getOAuthLoginPopupForTokenUpdateUrl(
        withBroker broker: String? = nil,
        userId: String,
        userToken: String,
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

        self.oAuthService.getOAuthLoginPopupURLForTokenUpdate(
            withBroker: brokerName,
            userId: userId,
            userToken: userToken,
            oAuthCallbackUrl: relinkOAuthCallbackUrl,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
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
        linkedBrokerData: LinkedBrokerData,
        onSuccess: @escaping (_ linkedBroker: TradeItLinkedBroker) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let linkedLogin = self.connector.saveToKeychain(
            withUserId: linkedBrokerData.userId,
            andUserToken: linkedBrokerData.userToken,
            andBroker: linkedBrokerData.broker,
            andBrokerLongName: linkedBrokerData.brokerLongName,
            andLabel: linkedBrokerData.broker
        )

        if let linkedLogin = linkedLogin {
            let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
            linkedBroker.accounts = linkedBrokerData.accounts.map { accountData in
                TradeItLinkedBrokerAccount(linkedBroker: linkedBroker, accountData: accountData)
            }

            if linkedBrokerData.isLinkActivationPending {
                linkedBroker.error = TradeItErrorResult(title: "Activation In Progress", message: "Your \(linkedBroker.brokerLongName) link is being activated. Check back soon (up to two business days)", code: TradeItErrorCode.accountNotAvailable)
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
            let availableBrokersPromise = Promise<[TradeItBroker]> { seal in
                brokerService.getAvailableBrokers(
                    userCountryCode: TradeItSDK.userCountryCode,
                    onSuccess: { availableBrokers, featuredBrokerLabelText in
                        // TODO: Why are these optional?
                        if let featuredBrokerLabelText = featuredBrokerLabelText {
                            TradeItSDK.featuredBrokerLabelText = featuredBrokerLabelText
                            self.featuredBrokerLabelText = featuredBrokerLabelText
                        }

                        seal.fulfill(availableBrokers)
                    }, onFailure: { error in
                        self.availableBrokersPromise = nil
                        seal.reject(error)
                    }
                )
            }

            self.availableBrokersPromise = availableBrokersPromise

            return availableBrokersPromise
        }
    }

    private func removeBrokerLocally(linkedBroker: TradeItLinkedBroker) {
        self.oAuthService.unlinkLogin(
            login: linkedBroker.linkedLogin,
            localOnly: true,
            onSuccess: { _ in
                if let index = self.linkedBrokers.index(of: linkedBroker) {
                    TradeItSDK.linkedBrokerCache.remove(linkedBroker: linkedBroker)
                    self.linkedBrokers.remove(at: index)
                }
            },
            onFailure: { errorResult in
                print("\n\n=====> removeBrokerLocally error: \(String(describing: errorResult.errorCode)) - \(String(describing: errorResult.shortMessage)) - \(String(describing: errorResult.longMessages?.first))")
            }
        )
    }

    // MARK: Debugging

    @objc public func printLinkedBrokers() {
        print("\n\n=====> LINKED BROKERS:")

        self.linkedBrokers.forEach { linkedBroker in
            let linkedLogin = linkedBroker.linkedLogin
            let userToken = TradeItSDK.linkedBrokerManager.connector.userToken(fromKeychainId: linkedLogin.keychainId)

            print("=====> \(linkedBroker.brokerName)(\(linkedBroker.accounts.count) accounts)\n    accountsUpdated: \(String(describing: linkedBroker.accountsLastUpdated))\n    userId: \(linkedLogin.userId)\n    keychainId: \(linkedLogin.keychainId)\n    userToken: \(userToken ?? "MISSING USER TOKEN")\n    error: \(String(describing: linkedBroker.error?.errorCode)) - \(String(describing: linkedBroker.error?.shortMessage)) - \(String(describing: linkedBroker.error?.longMessages?.first))")

            print("        === ACCOUNTS ===")

            linkedBroker.accounts.forEach { account in
                print("        [\(account.accountNumber)][\(account.accountName)]")
                print("            balancesUpdated: \(String(describing: account.balanceLastUpdated)), buyingPower: \(String(describing: account.balance?.buyingPower)), userCanDisableMargin: \(String(describing: account.userCanDisableMargin))")
            }
        }

        print("=====> ===============\n\n")
    }
}

@objc public class LinkedBrokerData: NSObject {
    let userId: String
    let userToken: String
    let broker: String
    let brokerLongName: String
    let accounts: [LinkedBrokerAccountData]
    let isLinkActivationPending: Bool
    
    @objc public init(
        userId: String,
        userToken: String,
        broker: String,
        brokerLongName: String,
        accounts: [LinkedBrokerAccountData],
        isLinkActivationPending: Bool = false
    ) {
        self.userId = userId
        self.userToken = userToken
        self.broker = broker
        self.brokerLongName = brokerLongName
        self.accounts = accounts
        self.isLinkActivationPending = isLinkActivationPending
    }
}

@objc public class LinkedBrokerAccountData: NSObject {
    let name: String
    let number: String
    let baseCurrency: String
    let userCanDisableMargin: Bool
    
    @objc public init(
        name: String,
        number: String,
        baseCurrency: String,
        userCanDisableMargin: Bool
    ) {
        self.name = name
        self.number = number
        self.baseCurrency = baseCurrency
        self.userCanDisableMargin = userCanDisableMargin
    }
}

@objc public protocol TradeItOAuthDelegate {
    @objc optional func didLink(userId: String, userToken: String)
    @objc optional func didUnlink(userId: String)
}
