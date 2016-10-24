enum TradeItErrorCode: Int {
    case SYSTEM_ERROR = 100
    case BROKER_EXECUTION_ERROR = 200
    case BROKER_AUTHENTICATION_ERROR = 300
    case BROKER_ACCOUNT_ERROR = 400
    case PARAMS_ERROR = 500
    case SESSION_ERROR = 600
    case OAUTH_ERROR = 700
}

extension TradeItErrorResult {
    convenience init(title: String, message: String = "Unknown response sent from the server.", code: TradeItErrorCode = .SYSTEM_ERROR) {
        self.init()
        self.shortMessage = title
        self.longMessages = [message]
        self.systemMessage = message
        self.code = code.rawValue
    }

    func errorCode() -> TradeItErrorCode? {
        if let code = self.code?.integerValue {
            return TradeItErrorCode(rawValue: code)
        } else {
            return nil
        }
    }

    func requiresRelink() -> Bool {
        guard let integerCode = self.code?.integerValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return [TradeItErrorCode.BROKER_AUTHENTICATION_ERROR, TradeItErrorCode.OAUTH_ERROR].contains(errorCode)
    }

    func requiresAuthentication() -> Bool {
        guard let integerCode = self.code?.integerValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return errorCode == TradeItErrorCode.SESSION_ERROR || requiresRelink()
    }
}
