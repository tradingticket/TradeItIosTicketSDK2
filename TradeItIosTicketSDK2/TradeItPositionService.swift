@objc public class TradeItPositionService: NSObject {
    private let session: TradeItSession

    init(session: TradeItSession) {
        self.session = session
    }

    func getPositions(
        _ positionsRequest: TradeItGetPositionsRequest,
        onSuccess: @escaping (TradeItGetPositionsResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        positionsRequest.token = self.session.token

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: positionsRequest,
            emsAction: "position/getPositions",
            environment: self.session.connector.environment
        )

        self.session.connector.send(request, targetClassType: TradeItGetPositionsResult.self) { result in
            switch (result) {
            case let result as TradeItGetPositionsResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Could not retrieve account positions. Please try again."
                ))
            }
        }
    }
}
