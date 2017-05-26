@objc public class TradeItSDK: NSObject {
    private static var apiKey: String?
    private static var environment: TradeitEmsEnvironments?
    private static var configured = false

    public static let launcher = TradeItLauncher()
    public static var cookieService: CookieService = TradeItCookieService()
    public static var adService: AdService = NullAdService()
    public static var theme: TradeItTheme = TradeItTheme.light()
    public static var isPortfolioEnabled = true
    public static let yahooLauncher = TradeItYahooLauncher()
    public static let didLinkNotificationName = NSNotification.Name(rawValue: "TradeItSDKDidLink")
    public static let didUnlinkNotificationName = NSNotification.Name(rawValue: "TradeItSDKDidUnlink")
    internal static let linkedBrokerCache = TradeItLinkedBrokerCache()

    private static var _oAuthCallbackUrl: URL?
    public static var oAuthCallbackUrl: URL {
        get {
            precondition(_oAuthCallbackUrl != nil, "ERROR: oAuthCallbackUrl accessed without being set in TradeItSDK.configure()!")
            return _oAuthCallbackUrl!
        }
    }

    internal static var _linkedBrokerManager: TradeItLinkedBrokerManager?
    public static var linkedBrokerManager: TradeItLinkedBrokerManager {
        get {
            precondition(_linkedBrokerManager != nil, "ERROR: TradeItSDK.linkedBrokerManager referenced before calling TradeItSDK.configure()!")
            return _linkedBrokerManager!
        }
    }

    internal static var _marketDataService: MarketDataService?
    public static var marketDataService: MarketDataService {
        get {
            precondition(_marketDataService != nil, "ERROR: TradeItSDK.marketDataService referenced before calling TradeItSDK.configure()!")
            return _marketDataService!
        }
    }

    internal static var _symbolService: TradeItSymbolService?
    public static var symbolService: TradeItSymbolService {
        get {
            precondition(_symbolService != nil, "ERROR: TradeItSDK.symbolService referenced before calling TradeItSDK.configure()!")
            return _symbolService!
        }
    }

    private static var _brokerCenterService: TradeItBrokerCenterService?
    public static var brokerCenterService: TradeItBrokerCenterService {
        get {
            precondition(_brokerCenterService != nil, "ERROR: TradeItSDK.brokerCenterService referenced before calling TradeItSDK.configure()!")
            return _brokerCenterService!
        }
    }

    public static func set(host: String, forEnvironment env: TradeitEmsEnvironments) {
        TradeItRequestResultFactory.setHost(host, forEnvironment: env)
    }

    public static func configure(
        apiKey: String,
        oAuthCallbackUrl: URL,
        environment: TradeitEmsEnvironments = TradeItEmsProductionEnv
    ) {
        // We need this version of the configure method because Obj-C does not generate methods that allow for  omitting optional arguments with defaults, e.g. marketDataService
        self.configure(
            apiKey: apiKey,
            oAuthCallbackUrl: oAuthCallbackUrl,
            environment: environment,
            marketDataService: nil,
            cookieService: nil
        )
    }

    public static func configure(
        apiKey: String,
        oAuthCallbackUrl: URL,
        environment: TradeitEmsEnvironments = TradeItEmsProductionEnv,
        marketDataService: MarketDataService? = nil,
        cookieService: CookieService? = nil
    ) {
        if !self.configured {
            self.configured = true
            self.apiKey = apiKey
            self.environment = environment
            if let cookieService = cookieService {
                self.cookieService = cookieService
            }
            self._oAuthCallbackUrl = oAuthCallbackUrl
            self._linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
            self._marketDataService = marketDataService ?? TradeItMarketService(apiKey: apiKey, environment: environment)
            self._symbolService = TradeItSymbolService(apiKey: apiKey, environment: environment)
            self._brokerCenterService = TradeItBrokerCenterService(apiKey: apiKey, environment: environment)
        } else {
            print("Warning: TradeItSDK.configure() called multiple times. Ignoring.")
        }
    }
}

@objc public protocol CookieService {
    func getCookies() -> [HTTPCookie]
}

@objc public class TradeItCookieService: NSObject, CookieService {
    public func getCookies() -> [HTTPCookie] {
        return []
    }
}
