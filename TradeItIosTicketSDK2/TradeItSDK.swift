@objc public class TradeItSDK: NSObject {
    private static var apiKey: String?
    private static var environment: TradeitEmsEnvironments?
    private static var configured = false
    
    public static let launcher = TradeItLauncher()
    public static var theme: TradeItTheme = TradeItTheme.light()
    public static var isPortfolioEnabled = true
    public static let yahooLauncher = TradeItYahooLauncher()
    internal static let linkedBrokerCache = TradeItLinkedBrokerCache()

    private static var _oAuthCallbackUrl: URL?
    public static var oAuthCallbackUrl: URL {
        get {
            precondition(_oAuthCallbackUrl != nil, "ERROR: oAuthCallbackUrl accessed without being set in TradeItSDK.configure()!")
            return _oAuthCallbackUrl!
        }
        
        set(new) {
            self._oAuthCallbackUrl = new
        }
    }
    
    private static var _linkedBrokerManager: TradeItLinkedBrokerManager?
    public static var linkedBrokerManager: TradeItLinkedBrokerManager {
        get {
            precondition(_linkedBrokerManager != nil, "ERROR: TradeItSDK.linkedBrokerManager referenced before calling TradeItSDK.configure()!")
            return _linkedBrokerManager!
        }
    }

    internal static var _marketDataService: TradeItMarketService?
    public static var marketDataService: TradeItMarketService {
        get {
            precondition(_marketDataService != nil, "ERROR: TradeItSDK.marketDataService referenced before calling TradeItSDK.configure()!")
            return _marketDataService!
        }
    }

    private static var _brokerCenterService: TradeItBrokerCenterService?
    public static var brokerCenterService: TradeItBrokerCenterService {
        get {
            precondition(_brokerCenterService != nil, "ERROR: TradeItSDK.brokerCenterService referenced before calling TradeItSDK.configure()!")
            return _brokerCenterService!
        }
    }
    
    public static func configure(apiKey: String,
                                 oAuthCallbackUrl: URL,
                                 environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        self.oAuthCallbackUrl = oAuthCallbackUrl
        self.configure(apiKey: apiKey, environment: environment)
    }

    public static func configure(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        if !self.configured {
            self.configured = true
            self.apiKey = apiKey
            self.environment = environment
            self._linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
            self._marketDataService = TradeItMarketService(apiKey: apiKey, environment: environment)
            self._brokerCenterService = TradeItBrokerCenterService(apiKey: apiKey, environment: environment)
        } else {
            print("Warning: TradeItSDK.configure() called multiple times. Ignoring.")
        }
    }
}
