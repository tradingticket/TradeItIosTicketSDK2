class TradeItBrokerCenterService {
    var connector: TradeItConnector
    var sessionProvider: TradeItSessionProvider

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        sessionProvider = TradeItSessionProvider()
    }

    func getPublishers(onSuccess: @escaping ([TradeItBrokerCenterBroker]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
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
}
