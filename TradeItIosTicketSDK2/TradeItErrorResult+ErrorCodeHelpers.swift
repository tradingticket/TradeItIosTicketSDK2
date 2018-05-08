@objc public enum TradeItErrorCode: Int {
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
    @objc public var errorCode: TradeItErrorCode? {
        get {
            if let code = self.code?.intValue {
                return TradeItErrorCode(rawValue: code)
            } else {
                return nil
            }
        }

        set(new) {
            self.code = new?.rawValue as NSNumber?
        }
    }
    @objc public var title: String {
        get {
            return self.shortMessage ?? ""
        }
    }
    @objc public var message: String {
        get {
            let messages = (self.longMessages as? [String]) ?? []
            return messages.joined(separator: "\n\n")
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
    
    @objc public static func error(withSystemMessage systemMessage: String) -> TradeItErrorResult {
            let errorResult = TradeItErrorResult()
            errorResult.status = "ERROR"
            errorResult.errorCode = .systemError
            errorResult.systemMessage = systemMessage
            errorResult.shortMessage = "Request failed"
            errorResult.longMessages = ["Could not complete your request. Please try again."]
            return errorResult
    }
    
    @objc public static func tradeError(withSystemMessage systemMessage: String) -> TradeItErrorResult {
        let errorResult = TradeItErrorResult()
        errorResult.status = "ERROR"
        errorResult.errorCode = .brokerExecutionError
        errorResult.systemMessage = systemMessage
        errorResult.shortMessage = "Could not place your order"
        errorResult.longMessages = ["Trading is temporarily unavailable. Please try again later."]
        return errorResult
    }
    
    @objc public func requiresRelink() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return [TradeItErrorCode.brokerLinkError, TradeItErrorCode.oauthError].contains(errorCode)
    }

    @objc public func requiresAuthentication() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return [TradeItErrorCode.brokerAccountError, TradeItErrorCode.sessionError, TradeItErrorCode.accountNotAvailable].contains(errorCode)
    }
    
    @objc public func isAccountLinkDelayedError() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }
        return TradeItErrorCode.accountNotAvailable == errorCode
    }
}
