// TODO: Make generic?
)class TradeItEquityTradeService: NSObject {
    private let session: TradeItSession

    init(session: TradeItSession) {
        self.session = session
    }

    func previewTrade(
        _ data: TradeItPreviewTradeRequest,
        onSuccess: @escaping (TradeItPreviewTradeResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        data.token = self.session.token

        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: "order/previewStockOrEtfOrder",
            environment: self.session.connector.environment
        )

        self.session.connector.send(request, targetClassType: TradeItPreviewTradeResult.self) { result in
            switch (result) {
            case let result as TradeItPreviewTradeResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Preview failed",
                    message: "There was a problem previewing your order. Please try again."
                ))
            }
        }
    }

    func placeTrade(
        _ data: TradeItPlaceTradeRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void
    ) {
        data.token = self.session.token

        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: "order/placeStockOrEtfOrder",
            environment: self.session.connector.environment
        )
        self.session.connector.sendReturnJSON(request, withCompletionBlock: { result, jsonResponse in
            completionBlock(self.parsePlaceTradeResponse(result, jsonResponse))
        })
    }
    
    func answerSecurityQuestionPlaceOrder(_ answer: String, withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void) {
        let secRequest = TradeItSecurityQuestionRequest(token: self.session.token, andAnswer: answer)
        let request = TradeItRequestFactory.buildJsonRequest(
            for: secRequest,
            emsAction: "user/answerSecurityQuestion",
            environment: self.session.connector.environment
        )
        self.session.connector.sendReturnJSON(request, withCompletionBlock: { result, jsonResponse in
            completionBlock(self.parsePlaceTradeResponse(result, jsonResponse))
        })
    }
    
    private func parsePlaceTradeResponse(_ placeTradeResult: TradeItResult, _ json: String?) -> TradeItResult {
        guard let json = json else { return TradeItErrorResult.error(withSystemMessage: "No data returned from server") }
        
        if let securityQuestionResult = placeTradeResult as? TradeItSecurityQuestionResult {
            return securityQuestionResult
        } else if let error = placeTradeResult as? TradeItErrorResult {
            return error
        } else if let placeTradeResult = TradeItResultTransformer.transform(targetClassType: TradeItPlaceTradeResult.self, json: json) {
            return placeTradeResult
        } else {
            return TradeItErrorResult(
                title: "Place failed",
                message: "There was a problem placinging your order. Please try again."
            )
        }
    }
}
