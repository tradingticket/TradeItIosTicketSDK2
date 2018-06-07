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
    
    func cancelOrder(
        _ data: TradeItCancelOrderRequest,
        onSuccess: @escaping () -> Void,
        onVerifyUrl: @escaping (URL, _ completeCancelOrderChallenge: @escaping () -> Void) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
        ) {
        data.token = self.session.token
        
        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: "order/cancelOrder",
            environment: self.session.connector.environment
        )
        
        let cancelOrderResponseHandler = YCombinator { handler in
            { (result: TradeItResult?) in
                switch result {
                case let verifyOAuthURLResult as TradeItVerifyOAuthURLResult:
                    guard let oAuthUrl = verifyOAuthURLResult.oAuthUrl() else {
                        onFailure(
                            TradeItErrorResult(
                                title: "Received empty OAuth verify popup URL"
                            )
                        )
                        return
                    }
                    onVerifyUrl(
                        oAuthUrl,
                        {
                            self.completeCancelOrderChallenge(completionBlock: handler)
                        }
                    )
                case _ as TradeItAllOrderStatusResult:
                    onSuccess()
                case let errorResult as TradeItErrorResult:
                    onFailure(errorResult)
                default:
                    onFailure(TradeItErrorResult.tradeError(withSystemMessage: "Error canceling order."))
                }
            }
        }
        
        self.session.connector.send(request, targetClassType: TradeItAllOrderStatusResult.self) { result in
            cancelOrderResponseHandler(result)
        }
    }

    func completeCancelOrderChallenge(completionBlock: @escaping (TradeItResult) -> Void) {
        let complete1FARequest = TradeItComplete1FARequest(token: self.session.token)
        let request = TradeItRequestFactory.buildJsonRequest(
            for: complete1FARequest,
            emsAction: "user/complete1FA",
            environment: self.session.connector.environment
        )

        self.session.connector.send(request, targetClassType: TradeItAllOrderStatusResult.self) { result in
            completionBlock(
                result ?? TradeItErrorResult.error(withSystemMessage: "Error canceling order.")
            )
        }
    }
}
