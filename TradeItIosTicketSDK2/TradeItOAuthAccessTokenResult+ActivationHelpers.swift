enum TradeItAccountActivationTime: String {
    case IMMEDIATE
    case ONE_OR_TWO_BUSINESS_DAY
    case UNKNOWN
}

extension TradeItOAuthAccessTokenResult {
    func getActivationTime() -> TradeItAccountActivationTime? {
        if let activationTime = self.activationTime {
            return TradeItAccountActivationTime(rawValue: activationTime)
        } else {
            return .UNKNOWN
        }
    }
    
    func buildActivationTimeTradeItErrorResult() -> TradeItErrorResult {
        let shortMessage = self.shortMessage ?? ""
        let longMessages = (self.longMessages as? [String]) ?? []
        let longMessage = longMessages.first ?? ""
        return TradeItErrorResult(title: shortMessage, message: longMessage, code: TradeItErrorCode.accountNotAvailable)
    }
}
