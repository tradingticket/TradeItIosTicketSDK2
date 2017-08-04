import UIKit

@objc public class TradeItSDK: NSObject {

    // MARK: Non-settable properties

    private static let sdkInstance = TradeItSDK()
    private static var configured = false
    public static let launcher = TradeItLauncher()
    public static let yahooLauncher = TradeItYahooLauncher()
    public static let didLinkNotificationName = NSNotification.Name(rawValue: "TradeItSDKDidLink")
    public static let didUnlinkNotificationName = NSNotification.Name(rawValue: "TradeItSDKDidUnlink")

    internal static let linkedBrokerCache = TradeItLinkedBrokerCache()

    private var _apiKey: String?
    public static var apiKey: String {
        get {
            precondition(TradeItSDK.sdkInstance._apiKey != nil, "ERROR: TradeItSDK.apiKey accessed before calling TradeItSDK.configure()!")
            return TradeItSDK.sdkInstance._apiKey!
        }
    }

    private var _environment: TradeitEmsEnvironments?
    public static var environment: TradeitEmsEnvironments {
        get {
            precondition(TradeItSDK.sdkInstance._environment != nil, "ERROR: TradeItSDK.environment accessed before calling TradeItSDK.configure()!")
            return TradeItSDK.sdkInstance._environment!
        }
    }

    private var _linkedBrokerManager: TradeItLinkedBrokerManager?
    public static var linkedBrokerManager: TradeItLinkedBrokerManager {
        get {
            precondition(TradeItSDK.sdkInstance._linkedBrokerManager != nil, "ERROR: TradeItSDK.linkedBrokerManager referenced before calling TradeItSDK.configure()!")
            return TradeItSDK.sdkInstance._linkedBrokerManager!
        }
    }

    private var _symbolService: TradeItSymbolService?
    public static var symbolService: TradeItSymbolService {
        get {
            precondition(TradeItSDK.sdkInstance._symbolService != nil, "ERROR: TradeItSDK.symbolService referenced before calling TradeItSDK.configure()!")
            return TradeItSDK.sdkInstance._symbolService!
        }
    }

    private var _brokerCenterService: TradeItBrokerCenterService?
    public static var brokerCenterService: TradeItBrokerCenterService {
        get {
            precondition(TradeItSDK.sdkInstance._brokerCenterService != nil, "ERROR: TradeItSDK.brokerCenterService referenced before calling TradeItSDK.configure()!")
            return TradeItSDK.sdkInstance._brokerCenterService!
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

    private var _marketDataService: MarketDataService?
    public static var marketDataService: MarketDataService {
        get {
            precondition(TradeItSDK.sdkInstance._marketDataService != nil, "ERROR: TradeItSDK.marketDataService referenced before initializing!")
            return TradeItSDK.sdkInstance._marketDataService!
        }

        set(new) {
            TradeItSDK.sdkInstance._marketDataService = new
        }
    }

    private var _oAuthCallbackUrl: URL?
    public static var oAuthCallbackUrl: URL {
        get {
            precondition(TradeItSDK.sdkInstance._oAuthCallbackUrl != nil, "ERROR: TradeItSDK.oAuthCallbackUrl accessed without being set in TradeItSDK.configure()!")
            return TradeItSDK.sdkInstance._oAuthCallbackUrl!
        }

        set(new) {
            TradeItSDK.sdkInstance._oAuthCallbackUrl = new
        }
    }

    public static func set(host: String, forEnvironment env: TradeitEmsEnvironments) {
        TradeItRequestResultFactory.setHost(host, forEnvironment: env)
    }

    // MARK: Initializers

    fileprivate override init() {} // hide default constructor
    
    public static func configure(
        apiKey: String,
        oAuthCallbackUrl: URL,
        environment: TradeitEmsEnvironments = TradeItEmsProductionEnv
    ) -> TradeItSDK {
        // We need this version of the configure method because Obj-C does not generate methods that allow for  omitting optional arguments with defaults, e.g. marketDataService
        return TradeItSDK.configure(
            apiKey: apiKey,
            oAuthCallbackUrl: oAuthCallbackUrl,
            environment: environment,
            marketDataService: nil
        )
    }

    public static func configure(
        apiKey: String,
        oAuthCallbackUrl: URL,
        environment: TradeitEmsEnvironments = TradeItEmsProductionEnv,
        userCountryCode: String? = nil,
        marketDataService: MarketDataService? = nil,
        requestFactory: RequestFactory = DefaultRequestFactory(),
        brokerLogoService: BrokerLogoService = DefaultBrokerLogoService()
    ) -> TradeItSDK {
        guard !TradeItSDK.configured else {
            print("WARNING: TradeItSDK.configure() called multiple times. Ignoring.")
            return TradeItSDK.sdkInstance
        }
        TradeItSDK.configured = true

        TradeItRequestResultFactory.requestFactory = requestFactory

        TradeItSDK.brokerLogoService = brokerLogoService

        TradeItSDK.sdkInstance._apiKey = apiKey
        TradeItSDK.sdkInstance._environment = environment
        TradeItSDK.sdkInstance._oAuthCallbackUrl = oAuthCallbackUrl
        TradeItSDK.userCountryCode = userCountryCode
        TradeItSDK.sdkInstance._linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
        TradeItSDK.sdkInstance._marketDataService = marketDataService ?? TradeItMarketService(apiKey: apiKey, environment: environment)
        TradeItSDK.sdkInstance._symbolService = TradeItSymbolService(apiKey: apiKey, environment: environment)
        TradeItSDK.sdkInstance._brokerCenterService = TradeItBrokerCenterService(apiKey: apiKey, environment: environment)
        return TradeItSDK.sdkInstance
    }
    
    public func with(userCountryCode: String) -> TradeItSDK {
        TradeItSDK.userCountryCode = userCountryCode
        return self;
    }
    
    public func with(marketDataservice: MarketDataService) -> TradeItSDK {
        TradeItSDK.sdkInstance._marketDataService = marketDataservice
        return self;
    }
    
    public func with(requestFactory: RequestFactory) -> TradeItSDK {
        TradeItRequestResultFactory.requestFactory = requestFactory
        return self;
    }
    
    public func with(brokerLogoService: BrokerLogoService) -> TradeItSDK {
        TradeItSDK.brokerLogoService = brokerLogoService
        return self;
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

@objc public class DefaultRequestFactory: NSObject, RequestFactory {
    public func buildPostRequest(
        for url: URL,
        jsonPostBody: String,
        headers: [String : String]
    ) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpBody = jsonPostBody.data(using: .utf8)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers // TODO: Add Dictionary extension for merging dictionaries

        return request;
    }
}
