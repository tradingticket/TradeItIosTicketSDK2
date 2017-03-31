public enum TradeItErrorCode: Int {
    case systemError = 100
    case brokerExecutionError = 200
    case brokerLinkError = 300
    case brokerAccountError = 400
    case paramsError = 500
    case sessionError = 600
    case oauthError = 700
    case accountNotAvailable = 800
}

extension TradeItErrorResult: Error {
    public var errorCode: TradeItErrorCode? {
        if let code = self.code?.intValue {
            return TradeItErrorCode(rawValue: code)
        } else {
            return nil
        }
    }

    convenience init(title: String,
                     message: String = "Unknown response sent from the server.",
                     code: TradeItErrorCode = .systemError) {
        self.init()
        self.shortMessage = title
        self.longMessages = [message]
        self.systemMessage = message
        self.code = NSDecimalNumber(value: code.rawValue)
    }

    public func requiresRelink() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return [TradeItErrorCode.brokerLinkError, TradeItErrorCode.oauthError].contains(errorCode)
    }

    public func requiresAuthentication() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return [TradeItErrorCode.brokerAccountError, TradeItErrorCode.sessionError, TradeItErrorCode.accountNotAvailable].contains(errorCode)
    }
    
    public func isAccountLinkDelayedError() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }
        return TradeItErrorCode.accountNotAvailable == errorCode
    }
}
