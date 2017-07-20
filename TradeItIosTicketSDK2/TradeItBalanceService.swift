@objc public class TradeItBalanceService: NSObject {
    private let session: TradeItSession

    init(session: TradeItSession) {
        self.session = session
    }

    func getAccountOverview(
        _ accountOverviewRequest: TradeItAccountOverviewRequest,
        onSuccess: @escaping (TradeItAccountOverviewResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        accountOverviewRequest.token = self.session.token

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: accountOverviewRequest,
            emsAction: "balance/getAccountOverview",
            environment: self.session.connector.environment
        )

        self.session.connector.send(request, targetClassType: TradeItAccountOverviewResult.self) { result in
            switch (result) {
            case let result as TradeItAccountOverviewResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Could not retrieve account balances. Please try again."
                ))
            }
        }
    }
}
