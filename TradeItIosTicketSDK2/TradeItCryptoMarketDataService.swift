internal class TradeItCryptoMarketDataService: NSObject {
    private let session: TradeItSession
    
    init(session: TradeItSession) {
        self.session = session
    }
    
    func getCryptoQuote(
        _ cryptoMarketDataRequest: TradeItCryptoQuoteRequest,
        onSuccess: @escaping (TradeItCryptoQuoteResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        cryptoMarketDataRequest.token = self.session.token ?? ""
        
        let request = TradeItRequestFactory.buildJsonRequest(
            for: cryptoMarketDataRequest,
            emsAction: "brokermarketdata/getCryptoQuote",
            environment: self.session.connector.environment
        )
        
        self.session.connector.send(request, targetClassType: TradeItCryptoQuoteResult.self) { result in
            switch (result) {
            case let result as TradeItCryptoQuoteResult: onSuccess(result)
            case let error as TradeItErrorResult: onFailure(error)
            default:
                onFailure(TradeItErrorResult(
                    title: "Could not retrieve account balances. Please try again."
                ))
            }
        }
    }
}
