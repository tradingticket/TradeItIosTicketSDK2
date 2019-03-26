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
        onSecurityQuestion: @escaping (
            TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void
        ) -> Void,
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
                case _ as TradeItAllOrderStatusResult:
                    onSuccess()
                case let securityQuestion as TradeItSecurityQuestionResult:
                    onSecurityQuestion(
                        securityQuestion,
                        { securityQuestionAnswer in
                            self.answerSecurityQuestionCancelOrder(securityQuestionAnswer, withCompletionBlock: handler)
                        },
                        {
                            handler(
                                TradeItErrorResult(
                                    title: "Authentication failed",
                                    message: "The security question was canceled.",
                                    code: .sessionError
                                )
                            )
                        }
                    )
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
    
    func answerSecurityQuestionCancelOrder(_ answer: String, withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void) {
        let secRequest = TradeItSecurityQuestionRequest(token: self.session.token, securityAnswer: answer)
        let request = TradeItRequestFactory.buildJsonRequest(
            for: secRequest,
            emsAction: "user/answerSecurityQuestion",
            environment: self.session.connector.environment
        )
        self.session.connector.send(request, targetClassType: TradeItAllOrderStatusResult.self) { result in
            completionBlock(
                result ?? TradeItErrorResult.tradeError(withSystemMessage: "Error canceling order.")
            )
        }
    }
}
