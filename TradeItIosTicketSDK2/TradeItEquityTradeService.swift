protocol TradeService {
    associatedtype PreviewTradeRequest: TradeItAuthenticatedRequest
    associatedtype PreviewTradeResult: TradeItResult
    associatedtype PlaceTradeResult: TradeItResult
    static var previewTradeEndpoint: String { get }
    static var placeTradeEndpoint: String { get }
    var session: TradeItSession { get }

    init(session: TradeItSession)

    func previewTrade(
        _ data: Self.PreviewTradeRequest,
        onSuccess: @escaping (Self.PreviewTradeResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    )

    func placeTrade(
        _ data: TradeItPlaceTradeRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void
    )

    func answerSecurityQuestionPlaceOrder(
        _ answer: String,
        withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void
    )
}

extension TradeService {
    func previewTrade(
        _ data: Self.PreviewTradeRequest,
        onSuccess: @escaping (Self.PreviewTradeResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        data.token = self.session.token

        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: Self.previewTradeEndpoint,
            environment: self.session.connector.environment
        )

        self.session.connector.send(request, targetClassType: Self.PreviewTradeResult.self) { result in
            switch (result) {
            case let result as Self.PreviewTradeResult: onSuccess(result)
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
            emsAction: Self.placeTradeEndpoint,
            environment: self.session.connector.environment
        )
        self.session.connector.sendReturnJSON(request, withCompletionBlock: { result, jsonResponse in
            completionBlock(self.parsePlaceTradeResponse(result, jsonResponse))
        })
    }
    
    func answerSecurityQuestionPlaceOrder(
        _ answer: String,
        withCompletionBlock completionBlock: @escaping (TradeItResult) -> Void
    ) {
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
    
    private func parsePlaceTradeResponse(
        _ placeTradeResult: TradeItResult,
        _ json: String?
    ) -> TradeItResult {
        guard let json = json else { return TradeItErrorResult.error(withSystemMessage: "No data returned from server") }
        
        if let securityQuestionResult = placeTradeResult as? TradeItSecurityQuestionResult {
            return securityQuestionResult
        } else if let error = placeTradeResult as? TradeItErrorResult {
            return error
        } else if let placeTradeResult = TradeItResultTransformer.transform(
            targetClassType: Self.PlaceTradeResult.self,
            json: json
        ) {
            return placeTradeResult
        } else {
            return TradeItErrorResult(
                title: "Place failed",
                message: "There was a problem placinging your order. Please try again."
            )
        }
    }
}

class TradeItEquityTradeService: TradeService {
    typealias PreviewTradeRequest = TradeItPreviewTradeRequest
    typealias PreviewTradeResult = TradeItPreviewTradeResult
    typealias PlaceTradeResult = TradeItPlaceTradeResult
    static let previewTradeEndpoint = "order/previewStockOrEtfOrder"
    static let placeTradeEndpoint = "order/placeStockOrEtfOrder"
    var session: TradeItSession

    required init(session: TradeItSession) {
        self.session = session
    }
}
