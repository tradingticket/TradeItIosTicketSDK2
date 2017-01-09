@objc public enum TradeItErrorCode: Int {
    case systemError = 100
    case brokerExecutionError = 200
    case brokerAuthenticationError = 300
    case brokerAccountError = 400
    case paramsError = 500
    case sessionError = 600
    case oauthError = 700
}

@objc public class TradeItErrorResult: TradeItResult, Error {
    var systemMessage: String?
    var errorFields: [String?] = []
    var code: NSDecimalNumber?
    public override var description: String {
        return "TradeItErrorResult: \(super.description) errorFields=\(self.errorFields) systemMessage=\(self.systemMessage)"
    }

    public convenience init(title: String,
         message: String = "Unknown response sent from the server.",
         code: TradeItErrorCode = .systemError) {
        self.init()
        self.shortMessage = title
        self.longMessages = [message]
        self.systemMessage = message
        self.code = NSDecimalNumber(value: code.rawValue)
    }

    public static func tradeError(systemMessage: String) -> TradeItErrorResult {
        return TradeItErrorResult(
            title: "Could Not Complete Your Order",
            message: "Trading is temporarily unavailable. Please try again in a few minutes."
        )
    }

    public func errorCode() -> TradeItErrorCode? {
        if let code = self.code?.intValue {
            return TradeItErrorCode(rawValue: code)
        } else {
            return nil
        }
    }

    public func requiresRelink() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }

        return [TradeItErrorCode.brokerAuthenticationError, TradeItErrorCode.oauthError].contains(errorCode)
    }

    public func requiresAuthentication() -> Bool {
        guard let integerCode = self.code?.intValue
            , let errorCode = TradeItErrorCode(rawValue: integerCode)
            else { return false }
        
        return [TradeItErrorCode.brokerAccountError, TradeItErrorCode.sessionError].contains(errorCode)
    }
}
