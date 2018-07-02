import PromiseKit

class TradeItUiConfigService: NSObject {
    private let connector: TradeItConnector
    private var uiConfigPromise: Promise<TradeItUiConfigResult>? = nil
    var isEnabled = true

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    func getUiConfigPromise() -> Promise<TradeItUiConfigResult> {
        if !isEnabled {
            return Promise.value(TradeItUiConfigResult())
        }

        if let uiConfigPromise = self.uiConfigPromise { return uiConfigPromise }

        let uiConfigRequest = TradeItUiConfigRequest(apiKey: connector.apiKey)

        let request = TradeItRequestFactory.buildJsonRequest(
            for: uiConfigRequest,
            emsAction: "ui/config",
            environment: self.connector.environment
        )

        let uiConfigPromise = self.connector.send(request, targetClassType: TradeItUiConfigResult.self)

        self.uiConfigPromise = uiConfigPromise

        return uiConfigPromise
    }
}
