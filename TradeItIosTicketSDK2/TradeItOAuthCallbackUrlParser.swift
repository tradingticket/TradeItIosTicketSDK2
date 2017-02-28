enum OAuthCallbackDestinationValues: String {
    case trading = "trading"
    case portfolio = "portfolio"
    case accountSelection = "accountSelection"
}

enum OAuthCallbackQueryParamKeys: String {
    case oAuthVerifier = "oAuthVerifier"
    case tradeItDestination = "tradeItDestination"
    case tradeItOrderSymbol = "tradeItOrderSymbol"
    case tradeItOrderAction = "tradeItOrderAction"
}

class TradeItOAuthCallbackUrlParser {
    let oAuthCallbackUrl: URL
    var oAuthVerifier: String?
    var destination: OAuthCallbackDestinationValues?
    var order: TradeItOrder?

    var oAuthCallbackUrlWithoutOauthVerifier: URL? {
        var urlComponents = URLComponents(url: oAuthCallbackUrl, resolvingAgainstBaseURL: false)
        urlComponents?.addOrUpdateQueryStringValue(
            forKey: OAuthCallbackQueryParamKeys.oAuthVerifier.rawValue,
            value: nil
        )

        return urlComponents?.url
    }

    init(oAuthCallbackUrl: URL) {
        self.oAuthCallbackUrl = oAuthCallbackUrl

        let urlComponents = URLComponents(url: oAuthCallbackUrl, resolvingAgainstBaseURL: false)

        self.oAuthVerifier = urlComponents?.queryStringValue(forKey: OAuthCallbackQueryParamKeys.oAuthVerifier.rawValue)

        if let destinationString = urlComponents?.queryStringValue(forKey: OAuthCallbackQueryParamKeys.tradeItDestination.rawValue) {
            self.destination = OAuthCallbackDestinationValues(rawValue: destinationString)
        }

        if self.destination == .trading {
            let symbol = urlComponents?.queryStringValue(forKey: OAuthCallbackQueryParamKeys.tradeItOrderSymbol.rawValue)
            var action = TradeItOrderActionPresenter.DEFAULT

            if let actionString = urlComponents?.queryStringValue(forKey: OAuthCallbackQueryParamKeys.tradeItOrderAction.rawValue) {
                action = TradeItOrderActionPresenter.enumFor(actionString)
            }

            self.order = TradeItOrder(symbol: symbol, action: action)
        }
    }
}
