class TradeItBrokerService {
    private let connector: TradeItConnector

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    func getAvailableBrokers(
        userCountryCode: String?,
        onSuccess: @escaping ([TradeItBroker], String?) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let data = TradeItBrokerListRequest(apiKey: self.connector.apiKey, userCountryCode: userCountryCode)

        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: "preference/getBrokerList?fidelityPilot=true",
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItBrokerListResult.self) { result in
            if let result = result as? TradeItBrokerListResult,
                let brokerList = result.brokerList as? [TradeItBroker] {
                onSuccess(brokerList, result.featuredBrokerLabel)
            } else if let error = result as? TradeItErrorResult {
                onFailure(error)
            } else {
                onFailure(TradeItErrorResult(
                    title: "Available brokers failure",
                    message: "Could not fetch the list of available brokers. Please try again later."
                ))
            }
        }
    }
}
