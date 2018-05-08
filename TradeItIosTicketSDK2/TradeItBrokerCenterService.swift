@objc public class TradeItBrokerCenterService: NSObject {
    let apiKey: String
    let environment: TradeitEmsEnvironments

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        self.apiKey = apiKey
        self.environment = environment
    }

    @objc public func getUrl() -> String {
        return TradeItRequestFactory.getHostForEnvironment(environment) + "brokerCenter?apiKey=\(apiKey)"
    }
}
