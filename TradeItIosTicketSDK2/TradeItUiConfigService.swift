class TradeItUiConfigService: NSObject {
    private let connector: TradeItConnector

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    func getUiConfig(
        onSuccess: @escaping (TradeItUiConfigResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let uiConfig = TradeItUiConfigRequest(apiKey: connector.apiKey)

        let request = TradeItRequestFactory.buildJsonRequest(
            for: uiConfig,
            emsAction: "ui/config",
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItUiConfigResult.self) { result in
            switch (result) {
            case let result as TradeItUiConfigResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Could not retrieve UI config. Please try again."
                ))
            }
        }
    }
}
