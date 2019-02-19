
internal class TradeItProxyVoteService: NSObject {
    private let session: TradeItSession
    
    init(session: TradeItSession) {
        self.session = session
    }
    
    func getProxyVoteUrl(
        _ proxyVoteUrlRequest: TradeItGetProxyVoteUrlRequest,
        onSuccess: @escaping (TradeItGetProxyVoteUrlResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        proxyVoteUrlRequest.token = self.session.token
        
        let request = TradeItRequestFactory.buildJsonRequest(
            for: proxyVoteUrlRequest,
            emsAction: "proxyvote/getProxyVoteUrl",
            environment: self.session.connector.environment
        )
        
        self.session.connector.send(request, targetClassType: TradeItGetProxyVoteUrlResult.self) { result in
            switch (result) {
            case let result as TradeItGetProxyVoteUrlResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Could not retrieve proxy vote url. Please try again."
                ))
            }
        }
    }
}
