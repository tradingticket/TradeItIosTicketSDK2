@objc public class TradeItSDK: NSObject {
    private static var apiKey: String?
    private static var environment: TradeitEmsEnvironments?

    public static let launcher = TradeItLauncher()
    private (set) public static var linkedBrokerManager: TradeItLinkedBrokerManager!
    private (set) public static var marketDataService: TradeItMarketService!
    private (set) public static var brokerCenterService: TradeItBrokerCenterService!

    public static func configure(apiKey: String, environment: TradeitEmsEnvironments = TradeItEmsProductionEnv) {
        if self.apiKey == nil {
            self.apiKey = apiKey
            self.environment = environment
            self.linkedBrokerManager = TradeItLinkedBrokerManager(apiKey: apiKey, environment: environment)
            self.marketDataService = TradeItMarketService(apiKey: apiKey, environment: environment)
            self.brokerCenterService = TradeItBrokerCenterService(apiKey: apiKey, environment: environment)
        } else {
            print("Warning: TradeItSDK.configure called multiple times. Ignoring.")
        }
    }
}
