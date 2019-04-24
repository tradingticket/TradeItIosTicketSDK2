class TradeItOAuthLoginPopupUrlForTokenUpdateResult: TradeItResult {
    var oAuthURL: String?
    var oAuthUrl: URL? {
        return oAuthURL != nil ? URL(string: oAuthURL!) : nil
    }
}
