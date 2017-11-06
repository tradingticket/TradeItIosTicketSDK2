import UIKit

internal class TradeItTransactionService: NSObject {

    private let session: TradeItSession
    
    init(session: TradeItSession) {
        self.session = session
    }
    
    func getTransactionsHistory(
        _ data: TradeItTransactionsHistoryRequest,
        onSuccess: @escaping (TradeItTransactionsHistoryResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        data.token = self.session.token
        
        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: "account/getAllTransactionsHistory",
            environment: self.session.connector.environment
        )
        
        self.session.connector.send(request, targetClassType: TradeItTransactionsHistoryResult.self) { result in
            switch (result) {
            case let result as TradeItTransactionsHistoryResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Fetching transactions history failed",
                    message: "There was a problem fetching transactions history. Please try again."
                ))
            }
        }
    }
}
