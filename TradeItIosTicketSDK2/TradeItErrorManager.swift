class TradeItErrorManager {

    func isBrokerAuthenticationError(error: TradeItErrorResult) -> Bool {
        guard let code = error.code
            else { return false }
        return (code == TradeItErrorCode.BROKER_AUTHENTICATION_ERROR.rawValue)
    }
    
    func isOAuthError(error: TradeItErrorResult) -> Bool {
        guard let code = error.code
            else { return false }
        return (code == TradeItErrorCode.OAUTH_ERROR.rawValue)
    }
    
    func isSessionError(error: TradeItErrorResult) -> Bool {
        guard let code = error.code
            else { return false }
        return (code == TradeItErrorCode.SESSION_ERROR.rawValue)
    }

}
