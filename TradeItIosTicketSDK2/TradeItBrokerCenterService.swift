@objc public class TradeItBrokerCenterService: NSObject {
    let connector: TradeItConnector
    let sessionProvider: TradeItSessionProvider

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        sessionProvider = TradeItSessionProvider()
    }

    public func getBrokers(onSuccess: @escaping ([TradeItBrokerCenterBroker]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let publisherService = TradeItPublisherService(connector: connector)
        let publisherRequest = TradeItPublisherDataRequest()

        publisherService?.getPublisherData(publisherRequest, withCompletionBlock: { tradeItResult in
            if let publisherDataResult = tradeItResult as? TradeItPublisherDataResult,
                let publishers = publisherDataResult.brokers as? [TradeItBrokerCenterBroker] {
                onSuccess(publishers)
            } else if let errorResult = tradeItResult as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Publisher Data failed", message: "Fetching publisher data. Please try again later."))
            }
        })
    }

    public func getButtonUrl(broker: String) -> String {
        guard let baseUrl = TradeItJsonConverter.getEmsBaseUrl(forEnvironment: connector.environment),
            let apiKey = connector.apiKey
            else { return "" }

        return "\(baseUrl)publisherad/brokerCenterPromptAdView?apiKey=\(apiKey)-key&broker=\(broker)"
    }
}
