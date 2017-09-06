internal class TradeItOrderService: NSObject {

    private let session: TradeItSession
    
    init(session: TradeItSession) {
        self.session = session
    }

    func getAllOrderStatus(
        _ data: TradeItAllOrderStatusRequest,
        onSuccess: @escaping (TradeItAllOrderStatusResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) {
        
        data.token = self.session.token
        
        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: "order/getAllOrderStatus",
            environment: self.session.connector.environment
        )
        
        self.session.connector.send(request, targetClassType: TradeItAllOrderStatusResult.self) { result in
            switch (result) {
            case let result as TradeItAllOrderStatusResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Fetching orders failed",
                    message: "There was a problem fetching orders. Please try again."
                ))
            }
        }

    }
}
