@objc public class TradeItFxTradeService: NSObject {
    private let session: TradeItSession

    init(session: TradeItSession) {
        self.session = session
    }

    func place(
        order: TradeItFxPlaceOrderRequest,
        onSuccess: @escaping (TradeItFxPlaceOrderResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        order.token = self.session.token

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: order,
            emsAction: "order/placeFxOrder",
            environment: self.session.connector.environment
        )

        self.session.connector.send(request, targetClassType: TradeItFxPlaceOrderResult.self, withCompletionBlock: { result in
            switch (result) {
            case let placeOrderResult as TradeItFxPlaceOrderResult:
                onSuccess(placeOrderResult)
            case let error as TradeItErrorResult:
                onFailure(error)
            default:
                onFailure(
                    TradeItErrorResult(
                        title: "Received invalid response",
                        message: "Please check your active orders and try again."
                    )
                )
            }
        })
    }

    func getOrderCapabilities(
        linkedBrokerAccount: TradeItLinkedBrokerAccount?,
        symbol: String?,
        onSuccess: @escaping (TradeItFxOrderCapabilities) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let requestData = TradeItOrderCapabilitiesRequest()
        requestData.accountNumber = linkedBrokerAccount?.accountNumber
        requestData.symbol = symbol
        requestData.token = self.session.token

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: requestData,
            emsAction: "order/getFxOrderCapabilities",
            environment: self.session.connector.environment
        )

        self.session.connector.send(request, targetClassType: TradeItFxOrderCapabilitiesResult.self, withCompletionBlock: { result in
            switch result {
            case let orderCapabilitiesResult as TradeItFxOrderCapabilitiesResult:
                onSuccess(orderCapabilitiesResult.orderCapabilities)
            case let error as TradeItErrorResult:
                onFailure(error)
            default:
                onFailure(TradeItErrorResult.error(withSystemMessage: "Unknown error fetching FxOrderCapabilities"))
            }
        })
    }
}
