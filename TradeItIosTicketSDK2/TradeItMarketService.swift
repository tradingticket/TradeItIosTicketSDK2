@objc public protocol MarketDataService {
    @objc func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    )

    @objc optional func getQuotes(
        symbols: [String],
        onSuccess: @escaping ([TradeItQuote]) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    )
}

@objc public protocol StreamingMarketDataService {
    @objc func startUpdatingQuote(
        forSymbol symbol: String,
        onUpdate: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping () -> Void
    )
    
    @objc func stopUpdatingQuote()
}

class TradeItMarketService: MarketDataService {
    let connector: TradeItConnector

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.getQuotes(
            symbols: [symbol],
            onSuccess: { quotes in
                if let quote = quotes.first(where: { $0.symbol == symbol }) {
                    onSuccess(quote)
                } else {
                    onFailure(TradeItErrorResult(title: "Symbol not found", message: "Could not fetch quote. Please try again."))
                }
            },
            onFailure: onFailure
        )
    }

    func getQuotes(
        symbols: [String],
        onSuccess: @escaping ([TradeItQuote]) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let quoteRequest = TradeItQuotesRequest(
            symbols: symbols,
            andApiKey: self.connector.apiKey
        )

        let request = TradeItRequestFactory.buildJsonRequest(
            for: quoteRequest,
            emsAction: getEndpoint(forRequest: quoteRequest) ?? "",
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItQuotesResult.self, withCompletionBlock: { result in
            if let quotesResult = result as? TradeItQuotesResult,
                let quotes = quotesResult.quotes as? [TradeItQuote] {
                onSuccess(quotes)
            } else if let errorResult = result as? TradeItErrorResult {
                onFailure(errorResult)
            } else {
                onFailure(TradeItErrorResult(title: "Market data failure", message: "Could not fetch quotes. Please try again."))
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
