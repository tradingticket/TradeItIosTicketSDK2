@objc public class TradeItOauthService: NSObject {
    private let connector: TradeItConnector
    
    init(connector: TradeItConnector) {
        self.connector = connector
    }
    
    func getOAuthLoginPopupUrlForMobile(
        withBroker broker: String ,
        oAuthCallbackUrl: URL,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        
        let data = TradeItOAuthLoginPopupUrlForMobileRequest(apiKey: self.connector.apiKey, broker: broker, interAppAddressCallback: oAuthCallbackUrl.absoluteString)
        
        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "user/getOAuthLoginPopupUrlForMobile",
            environment: self.connector.environment
        )
        
        self.connector.send(request, targetClassType: TradeItOAuthLoginPopupUrlForMobileResult.self) { result in
            switch (result) {
            case let result as TradeItOAuthLoginPopupUrlForMobileResult:
                guard let oAuthUrl = result.oAuthUrl() else {
                    onFailure(
                        TradeItErrorResult(
                            title: "Received empty URL for broker linking"
                        )
                    )
                    return
                }
                
                onSuccess(oAuthUrl)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Could not retrieve URL for broker linking"
                    )
                )
            }
        }
    }
    
    func getOAuthLoginPopupURLForTokenUpdate(
        withBroker broker: String,
        userId: String,
        oAuthCallbackUrl: URL,
        onSuccess: @escaping (_ oAuthLoginPopupUrl: URL) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) -> Void {
        
        let data = TradeItOAuthLoginPopupUrlForTokenUpdateRequest(
            apiKey: self.connector.apiKey,
            broker: broker,
            userId: userId,
            interAppAddressCallback: oAuthCallbackUrl.absoluteString
        )
        
        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "user/getOAuthLoginPopupURLForTokenUpdate",
            environment: self.connector.environment
        )
        
        self.connector.send(request, targetClassType: TradeItOAuthLoginPopupUrlForTokenUpdateResult.self) { result in
            switch result {
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
    
    func getOAuthAccessToken(
        withOAuthVerifier oAuthVerifier: String,
        onSuccess: @escaping (_ oAuthAccessTokenResult: TradeItOAuthAccessTokenResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) -> Void {
        
        let data = TradeItOAuthAccessTokenRequest(
            apiKey: self.connector.apiKey,
            oAuthVerifier: oAuthVerifier
        )
        
        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "user/getOAuthAccessToken",
            environment: self.connector.environment
        )
        
        self.connector.send(request, targetClassType: TradeItOAuthAccessTokenResult.self) { result in
            switch result {
            case let errorResult as TradeItErrorResult: onFailure(errorResult)
            case let oAuthAccessTokenResult as TradeItOAuthAccessTokenResult: onSuccess(oAuthAccessTokenResult)
            default:
                onFailure(TradeItErrorResult(
                    title: "Broker linking failed",
                    message: "Please try again."
                ))
            }
        }
    }
    
    func unlinkLogin(
        login: TradeItLinkedLogin,
        localOnly: Bool,
        onSuccess: @escaping (_ unlinkLoginResult: TradeItUnlinkLoginResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) {
        if localOnly {
            self.connector.deleteLocalLinkedLogin(login)
            let result = TradeItUnlinkLoginResult()
            result.status = "SUCCESS"
            result.shortMessage = "Broker succesfully unlinked"
            onSuccess(result)
        } else {
            self.oAuthDeleteLink(
                withLinkedLogin: login,
                onSuccess: { result in
                    if result.isSuccessful() {
                        self.connector.deleteLocalLinkedLogin(login)
                    }
                    onSuccess(result)
                },
                onFailure: onFailure
            )
        }
    }
    
    // MARK: Internal
    
    @available(*, deprecated, message: "See documentation for supporting oAuth flow.")
    internal func updateUserToken(
        linkedlogin:TradeItLinkedLogin,
        authInfo: TradeItAuthenticationInfo,
        onSuccess: @escaping (_ updateLinkResult: TradeItUpdateLinkResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) -> Void {
        
        let data = TradeItUpdateLinkRequest(
            userId: linkedlogin.userId,
            authInfo: authInfo,
            apiKey: self.connector.apiKey
        )
        
        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "user/oAuthUpdate",
            environment: self.connector.environment
        )
        
        self.connector.send(request, targetClassType: TradeItUpdateLinkResult.self) { result in
            switch result {
                case let updateLinkResult as TradeItUpdateLinkResult: onSuccess(updateLinkResult)
                case let errorResult as TradeItErrorResult: onFailure(errorResult)
                default:
                    let error = TradeItErrorResult(title: "OAuth update error")
                    onFailure(error)
                
            }
        }
    }
    
    // MARK: Private
    
    private func oAuthDeleteLink(
        withLinkedLogin linkedLogin: TradeItLinkedLogin,
        onSuccess: @escaping (_ unlinkLoginResult: TradeItUnlinkLoginResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) -> Void {
        
        let data = TradeItOAuthDeleteLinkRequest(
            apiKey: self.connector.apiKey,
            userId: linkedLogin.userId,
            userToken: self.connector.userToken(fromKeychainId: linkedLogin.keychainId) ?? ""
        )
        
        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "user/oAuthDelete",
            environment: self.connector.environment
        )
        
        self.connector.send(request, targetClassType: TradeItUnlinkLoginResult.self) { result in
            switch result {
            case let errorResult as TradeItErrorResult: onFailure(errorResult)
            case let unlinkLoginResult as TradeItUnlinkLoginResult: onSuccess(unlinkLoginResult)
            default:
                onFailure(TradeItErrorResult(
                    title: "OAuth delete error"
                ))
            }
        }
    }
}
