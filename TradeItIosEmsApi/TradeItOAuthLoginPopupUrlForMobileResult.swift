class TradeItOAuthLoginPopupUrlForMobileResult: TradeItResult {
    var oAuthURL: String?
    var oAuthUrl: URL? {
        return oAuthURL ? URL(string: oAuthURL) : nil
    }
}
