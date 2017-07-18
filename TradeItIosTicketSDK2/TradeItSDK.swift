import UIKit

@objc public class TradeItSDK: NSObject {

    // MARK: Non-settable properties

    private static var configured = false

    public static let launcher = TradeItLauncher()
    public static let yahooLauncher = TradeItYahooLauncher()
    public static let didLinkNotificationName = NSNotification.Name(rawValue: "TradeItSDKDidLink")
    public static let didUnlinkNotificationName = NSNotification.Name(rawValue: "TradeItSDKDidUnlink")

    internal static let linkedBrokerCache = TradeItLinkedBrokerCache()

    private static var _apiKey: String?
    public static var apiKey: String {
        get {
            precondition(self._apiKey != nil, "ERROR: TradeItSDK.apiKey accessed before calling TradeItSDK.configure()!")
            return self._apiKey!
        }
    }

    private static var _environment: TradeitEmsEnvironments?
    public static var environment: TradeitEmsEnvironments {
        get {
            precondition(self._environment != nil, "ERROR: TradeItSDK.environment accessed before calling TradeItSDK.configure()!")
            return self._environment!
        }
    }

    internal static var _linkedBrokerManager: TradeItLinkedBrokerManager?
    public static var linkedBrokerManager: TradeItLinkedBrokerManager {
        get {
            precondition(self._linkedBrokerManager != nil, "ERROR: TradeItSDK.linkedBrokerManager referenced before calling TradeItSDK.configure()!")
            return self._linkedBrokerManager!
        }
    }

    internal static var _symbolService: TradeItSymbolService?
    public static var symbolService: TradeItSymbolService {
        get {
            precondition(self._symbolService != nil, "ERROR: TradeItSDK.symbolService referenced before calling TradeItSDK.configure()!")
            return self._symbolService!
        }
    }

    private static var _brokerCenterService: TradeItBrokerCenterService?
    public static var brokerCenterService: TradeItBrokerCenterService {
        get {
            precondition(self._brokerCenterService != nil, "ERROR: TradeItSDK.brokerCenterService referenced before calling TradeItSDK.configure()!")
            return self._brokerCenterService!
        }
    }

    // MARK: Settable properties

    public static var theme: TradeItTheme = TradeItTheme.light()
    public static var isPortfolioEnabled = true
    public static var isAdServiceEnabled = false
    public static var userCountryCode: String? // CountryCode matching standard: ISO3166 alpha-2. Used for managing broker availability.
    public static var adService: AdService = DefaultAdService()
    public static var brokerLogoService: BrokerLogoService = DefaultBrokerLogoService()
    public static var welcomeScreenHeadlineText: String = "Link your broker account to enable:"
    public static var featuredBrokerLabelText: String = "SPONSORED BROKER"

    internal static var _marketDataService: MarketDataService?
    public static var marketDataService: MarketDataService {
        get {
            precondition(self._marketDataService != nil, "ERROR: TradeItSDK.marketDataService referenced before initializing!")
            return self._marketDataService!
        }

        set(new) {
            self._marketDataService = new
        }
    }

    private static var _oAuthCallbackUrl: URL?
    public static var oAuthCallbackUrl: URL {
        get {
            precondition(self._oAuthCallbackUrl != nil, "ERROR: TradeItSDK.oAuthCallbackUrl accessed without being set in TradeItSDK.configure()!")
            return self._oAuthCallbackUrl!
        }

        set(new) {
            self._oAuthCallbackUrl = new
        }
    }

    public static func set(host: String, forEnvironment env: TradeitEmsEnvironments) {
        TradeItRequestResultFactory.setHost(host, forEnvironment: env)
    }

    // MARK: Initializers

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
            brokerLogoService: nil
        )
    }

    public static func configure(
        apiKey: String,
        oAuthCallbackUrl: URL,
        environment: TradeitEmsEnvironments = TradeItEmsProductionEnv,
        userCountryCode: String? = nil,
        marketDataService: MarketDataService? = nil,
        requestFactory: RequestFactory? = nil,
        brokerLogoService: BrokerLogoService? = nil
    ) {
        guard !self.configured else {
            print("WARNING: TradeItSDK.configure() called multiple times. Ignoring.")
            return
        }

        self.configured = true

        self.brokerLogoService = brokerLogoService ?? DefaultBrokerLogoService()

        self._apiKey = apiKey
        self._environment = environment
        self._oAuthCallbackUrl = oAuthCallbackUrl
        self.userCountryCode = userCountryCode
        self._linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
        self._marketDataService = marketDataService ?? TradeItMarketService(apiKey: apiKey, environment: environment)
        self._symbolService = TradeItSymbolService(apiKey: apiKey, environment: environment)
        self._brokerCenterService = TradeItBrokerCenterService(apiKey: apiKey, environment: environment)

        if let requestFactory = requestFactory {
            TradeItRequestResultFactory.requestFactory = requestFactory
        }
    }
}

@objc public protocol BrokerLogoService {
    func getLogo(forBroker broker: String) -> UIImage?
}

@objc public class DefaultBrokerLogoService: NSObject, BrokerLogoService {
    public func getLogo(forBroker broker: String) -> UIImage? {
        return broker.lowercased() == "dummy" ? UIImage(named: "tradeit_logo.png") : nil
    }
}
