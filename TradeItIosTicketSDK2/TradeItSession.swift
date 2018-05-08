import AdSupport

@objc public class TradeItSession {
    let connector: TradeItConnector
    var token: String?

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    func authenticate(_ linkedLogin: TradeItLinkedLogin, withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void) {
        let userToken = self.connector.userToken(fromKeychainId: linkedLogin.keychainId) ?? ""
        let authRequest = TradeItAuthenticationRequest(
            userToken: userToken,
            userId: linkedLogin.userId,
            andApiKey: connector.apiKey,
            andAdvertisingId: getAdvertisingId()
        )

        let request = TradeItRequestFactory.buildJsonRequest(
            for: authRequest,
            emsAction: "user/authenticate",
            environment: connector.environment
        )

        self.connector.sendReturnJSON(request, withCompletionBlock: { result, jsonResponse in
            completionBlock(self.parseAuthResponse(result, jsonResponse))
        })
    }

    func getAdvertisingId() -> String? {
        if TradeItSDK.isAdServiceEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return nil
        }
    }

    func answerSecurityQuestion(_ answer: String, withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void) {
        let secRequest = TradeItSecurityQuestionRequest(token: self.token, andAnswer: answer)
        let request = TradeItRequestFactory.buildJsonRequest(
            for: secRequest,
            emsAction: "user/answerSecurityQuestion",
            environment: connector.environment
        )

        self.connector.sendReturnJSON(request, withCompletionBlock: { result, jsonResponse in
            completionBlock(self.parseAuthResponse(result, jsonResponse))
        })
    }

    private func parseAuthResponse(_ authenticationResult: TradeItResult, _ json: String?) -> TradeItResult {
        guard let json = json else { return TradeItErrorResult.error(withSystemMessage: "No data returned from server") }

        if let authenticationResult = TradeItResultTransformer.transform(targetClassType: TradeItAuthenticationResult.self, json: json) {
            self.token = authenticationResult.token
            return authenticationResult
        } else if let securityQuestionResult = authenticationResult as? TradeItSecurityQuestionResult {
            self.token = securityQuestionResult.token
            return securityQuestionResult
        } else if let error = authenticationResult as? TradeItErrorResult {
            return error
        } else {
            // TODO: Figure out what to do here
            return TradeItErrorResult.error(withSystemMessage: "Unknown error")
        }
    }
}
