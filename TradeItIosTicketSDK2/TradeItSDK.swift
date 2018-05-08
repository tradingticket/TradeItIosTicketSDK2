import UIKit

@objc public class TradeItSDK: NSObject {
    // MARK: Settable properties

    @objc public static var theme: TradeItTheme = TradeItTheme.light()
    @objc public static var isPortfolioEnabled = true
    @objc public static var isAdServiceEnabled = false
    @objc public static var userCountryCode: String? // CountryCode matching standard: ISO3166 alpha-2. Used for managing broker availability.
    @objc public static var adService: AdService = DefaultAdService()
    @objc public static var welcomeScreenHeadlineText: String = "Link your broker account to enable:"
    @objc public static var featuredBrokerLabelText: String = "SPONSORED BROKER"
    @objc public static var activityViewFactory: ActivityIndicatorFactory = DefaultActivityIndicatorFactory()

    // MARK: Non-settable properties

    internal static var brokerLogoService = TradeItBrokerLogoService()
    private static var configured = false

    @objc public static let launcher = TradeItLauncher()
    @objc public static let yahooLauncher = TradeItYahooLauncher()

    @available(*, deprecated, message: "Use TradeItNotification.Name.didLink (Swift) or TradeItNotificationConstants.nameDidLink (Obj-C) instead.")
    @objc public static var didLinkNotificationName: NSNotification.Name {
        get {
            return TradeItNotification.Name.didLink
        }
    }
    @available(*, deprecated, message: "Use TradeItNotification.Name.didUnlink (Swift) or TradeItNotificationConstants.nameDidUnlink (Obj-C) instead.")
    @objc public static var didUnlinkNotificationName: NSNotification.Name {
        get {
            return TradeItNotification.Name.didUnlink
        }
    }

    internal static let linkedBrokerCache = TradeItLinkedBrokerCache()

    private static var _apiKey: String?
    @objc public static var apiKey: String {
        get {
            precondition(self._apiKey != nil, "ERROR: TradeItSDK.apiKey accessed before calling TradeItSDK.configure()!")
            return self._apiKey!
        }
    }

    private static var _environment: TradeitEmsEnvironments?
    @objc public static var environment: TradeitEmsEnvironments {
        get {
            precondition(self._environment != nil, "ERROR: TradeItSDK.environment accessed before calling TradeItSDK.configure()!")
            return self._environment!
        }
    }

    internal static var _linkedBrokerManager: TradeItLinkedBrokerManager?
    @objc public static var linkedBrokerManager: TradeItLinkedBrokerManager {
        get {
            precondition(self._linkedBrokerManager != nil, "ERROR: TradeItSDK.linkedBrokerManager referenced before calling TradeItSDK.configure()!")
            return self._linkedBrokerManager!
        }
    }

    internal static var _symbolService: TradeItSymbolService?
    @objc public static var symbolService: TradeItSymbolService {
        get {
            precondition(self._symbolService != nil, "ERROR: TradeItSDK.symbolService referenced before calling TradeItSDK.configure()!")
            return self._symbolService!
        }
    }
    
    private static var _uiConfigService: TradeItUiConfigService?
    internal static var uiConfigService: TradeItUiConfigService {
        get {
            precondition(self._uiConfigService != nil, "ERROR: TradeItSDK.uiConfigService referenced before calling TradeItSDK.configure()!")
            return self._uiConfigService!
        }
    }

    private static var _brokerCenterService: TradeItBrokerCenterService?
    @objc public static var brokerCenterService: TradeItBrokerCenterService {
        get {
            precondition(self._brokerCenterService != nil, "ERROR: TradeItSDK.brokerCenterService referenced before calling TradeItSDK.configure()!")
            return self._brokerCenterService!
        }
    }

    internal static var _marketDataService: MarketDataService?
    @objc public static var marketDataService: MarketDataService {
        get {
            precondition(self._marketDataService != nil, "ERROR: TradeItSDK.marketDataService referenced before initializing!")
            return self._marketDataService!
        }

        set(new) {
            self._marketDataService = new
        }
    }

    private static var _oAuthCallbackUrl: URL?
    @objc public static var oAuthCallbackUrl: URL {
        get {
            precondition(self._oAuthCallbackUrl != nil, "ERROR: TradeItSDK.oAuthCallbackUrl accessed without being set in TradeItSDK.configure()!")
            return self._oAuthCallbackUrl!
        }

        set(new) {
            self._oAuthCallbackUrl = new
        }
    }

    private static var _isDeviceJailbroken = TradeItDeviceManager.isDeviceJailBroken()
    @objc public static var isDeviceJailbroken: Bool {
        get {
            return _isDeviceJailbroken
        }
    }
    
    @objc public static func set(host: String, forEnvironment env: TradeitEmsEnvironments) {
        TradeItRequestFactory.setHost(host, forEnvironment: env)
    }

    // MARK: Initializers

    @objc public static func configure(
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
            requestFactory: nil
        )
    }

    @objc public static func configure(
        apiKey: String,
        oAuthCallbackUrl: URL,
        environment: TradeitEmsEnvironments = TradeItEmsProductionEnv,
        userCountryCode: String? = nil,
        marketDataService: MarketDataService? = nil,
        requestFactory: RequestFactory? = nil
    ) {
        guard !self.configured else {
            print("WARNING: TradeItSDK.configure() called multiple times. Ignoring.")
            return
        }
        
        self.configured = true

        TradeItRequestFactory.setRequestFactory(requestFactory: requestFactory ?? DefaultRequestFactory())

        self._apiKey = apiKey
        self._environment = environment
        self._oAuthCallbackUrl = oAuthCallbackUrl
        self.userCountryCode = userCountryCode

        let connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        self._linkedBrokerManager = TradeItLinkedBrokerManager(connector: connector)
        self._marketDataService = marketDataService ?? TradeItMarketService(connector: connector)
        self._symbolService = TradeItSymbolService(connector: connector)
        self._brokerCenterService = TradeItBrokerCenterService(apiKey: apiKey, environment: environment)
        self._uiConfigService = TradeItUiConfigService(connector: connector)
    }
}
