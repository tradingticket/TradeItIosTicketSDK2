enum TradeItErrorCode: Int {
    case systemError = 100
    case brokerExecutionError = 200
    case brokerAuthenticationError = 300
    case brokerAccountError = 400
    case paramsError = 500
    case sessionError = 600
    case oauthError = 700
}

extension TradeItErrorResult {
    convenience init(title: String, message: String = "Unknown response sent from the server.", code: TradeItErrorCode = .systemError) {
        self.init()
        self.shortMessage = title
        self.longMessages = [message]
        self.systemMessage = message
        self.code = NSDecimalNumber(value: code.rawValue)
    }

    func errorCode() -> TradeItErrorCode? {
        if let code = self.code?.intValue {
            return TradeItErrorCode(rawValue: code)
        } else {
            return nil
        }
    }

    func requiresRelink() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return [TradeItErrorCode.brokerAuthenticationError, TradeItErrorCode.oauthError].contains(errorCode)
    }

    func requiresAuthentication() -> Bool {
        return !requiresRelink()
    }
}
