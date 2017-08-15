@objc public protocol MarketDataService {
    @objc func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    )
}

@objc public class TradeItMarketService: NSObject, MarketDataService {
    let connector: TradeItConnector

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    public func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let quoteRequest = TradeItQuotesRequest(
            symbol: symbol,
            andApiKey: self.connector.apiKey
        )

        let request = TradeItRequestFactory.buildJsonRequest(
            for: quoteRequest,
            emsAction: getEndpoint(forRequest: quoteRequest) ?? "",
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItQuotesResult.self, withCompletionBlock: { result in
            if let quotesResult = result as? TradeItQuotesResult,
                let quote = quotesResult.quotes?.first as? TradeItQuote {
                onSuccess(quote)
            } else if let errorResult = result as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Market data failure", message: "Could not fetch quote. Please try again."))
            }
        })
    }

    private func getEndpoint(forRequest request: TradeItQuotesRequest) -> String? {
        if request.suffixMarket != nil {
            return "marketdata/getYahooQuotes"
        } else if request.symbol != nil {
            return "marketdata/getQuote"
        } else if request.symbols != nil {
            return "marketdata/getQuotes"
        } else {
            return nil
        }
    }
}
