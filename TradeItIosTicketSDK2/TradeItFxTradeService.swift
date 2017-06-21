@objc public class TradeItFxTradeService: NSObject {
    private let session: TradeItSession
    private let defaultError = TradeItErrorResult(
        title: "Invalid response sent from the server",
        message: "Please check your active orders and try again."
    )


    init(session: TradeItSession) {
        self.session = session
    }

    func place(
        order: TradeItFxPlaceOrderRequest,
        onSuccess: @escaping (TradeItFxPlaceOrderResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) -> Void {
        order.token = self.session.token

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: order,
            emsAction: "order/placeFxOrder",
            environment: self.session.connector.environment
        )

        self.session.connector.sendEMSRequest(request, withCompletionBlock: { (result, jsonResponse) in
            guard let jsonResponse = jsonResponse as String? else {
                return onFailure(self.defaultError)
            }

            var parsedResult: TradeItResult = self.defaultError

            if (result?.status == "SUCCESS") {
                parsedResult = TradeItRequestResultFactory.build(TradeItFxPlaceOrderResult(), jsonString: jsonResponse)
            }

            switch (parsedResult) {
            case let placeOrderResult as TradeItFxPlaceOrderResult:
                onSuccess(placeOrderResult)
            case let error as TradeItErrorResult:
                onFailure(error)
            default:
                onFailure(self.defaultError)
            }
        })
    }
}
