@objc public class TradeItSDK: NSObject {
    private static var apiKey: String?
    private static var environment: TradeitEmsEnvironments?
    private static var configured = false
    public static let launcher = TradeItLauncher()
    internal static let linkedBrokerCache = TradeItLinkedBrokerCache()
    internal static var theme: TradeItTheme = TradeItTheme.light()

    internal static var _linkedBrokerManager: TradeItLinkedBrokerManager?
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

    public static func configure(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv, theme: TradeItTheme = TradeItTheme.light()) {
        if !self.configured {
            self.configured = true
            self.apiKey = apiKey
            self.environment = environment
            self.theme = theme
            self._linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
            self._marketDataService = TradeItMarketService(apiKey: apiKey, environment: environment)
            self._brokerCenterService = TradeItBrokerCenterService(apiKey: apiKey, environment: environment)
        } else {
            print("Warning: TradeItSDK.configure() called multiple times. Ignoring.")
        }
    }
}
