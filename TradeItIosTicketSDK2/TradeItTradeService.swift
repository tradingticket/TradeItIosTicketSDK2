@objc public class TradeItTradeService: NSObject {
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

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "order/previewStockOrEtfOrder",
            environment: self.session.connector.environment
        )

        self.session.connector.sendEMSRequest(request, forResultClass: TradeItPreviewTradeResult.self) { result in
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
        onSuccess: @escaping (TradeItPlaceTradeResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        data.token = self.session.token

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: data,
            emsAction: "order/placeStockOrEtfOrder",
            environment: self.session.connector.environment
        )

        self.session.connector.sendEMSRequest(request, forResultClass: TradeItPlaceTradeResult.self) { result in
            switch (result) {
            case let result as TradeItPlaceTradeResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Invalid response sent from the server",
                    message: "Please check your active orders and try again."
                ))
            }
        }
    }
}
