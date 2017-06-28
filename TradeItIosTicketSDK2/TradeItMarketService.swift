@objc public protocol MarketDataService {
    @objc func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    )
}

@objc public class TradeItSymbolService: NSObject {
    let marketDataService: TradeItMarketDataService

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        let connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        self.marketDataService = TradeItMarketDataService(connector: connector)
    }

    public func symbolLookup(_ searchText: String, onSuccess: @escaping ([TradeItSymbolLookupCompany]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let symbolLookupRequest = TradeItSymbolLookupRequest(query: searchText)

        self.marketDataService.symbolLookup(
            symbolLookupRequest,
            withCompletionBlock: { tradeItResult in
                if let symbolLookupResult = tradeItResult as? TradeItSymbolLookupResult,
                    let results = symbolLookupResult.results as? [TradeItSymbolLookupCompany] {
                    onSuccess(results)
                } else if let errorResult = tradeItResult as? TradeItErrorResult {
                    onFailure(errorResult)
                } else {
                    onFailure(TradeItErrorResult(title: "Market Data failed", message: "Fetching data for symbol lookup failed. Please try again later."))
                }
            }
        )
    }

    public func fxSymbols(forBroker broker: String, onSuccess: @escaping ([String]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        let requestData = TradeItFxSymbolsRequest()
        requestData.broker = broker
        requestData.apiKey = self.marketDataService.connector.apiKey!

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: requestData,
            emsAction: "brokermarketdata/getFxCurrencyPairs",
            environment: self.marketDataService.connector.environment
        )

        // TODO: Fix this. Our connector doesn't support a way to just get back a string array from JSON.
        self.marketDataService.connector.sendEMSRequest(request, withCompletionBlock: { result, jsonResponse in
            guard let data = jsonResponse?.data(using: String.Encoding.utf8.rawValue),
                let symbolsTemp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String],
                let symbols = symbolsTemp else {
                onFailure(TradeItErrorResult.error(withSystemMessage: "Failed to get FX symbols"))
                return
            }
            onSuccess(symbols)
        })
    }
}

@objc public class TradeItMarketService: NSObject, MarketDataService {
    let marketDataService: TradeItMarketDataService

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        let connector = TradeItConnector(apiKey: apiKey, environment: environment, version: TradeItEmsApiVersion_2)
        self.marketDataService = TradeItMarketDataService(connector: connector)
    }

    public func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let quotesRequest = TradeItQuotesRequest(symbol: symbol)

        self.getQuote(quoteRequest: quotesRequest, onSuccess: onSuccess, onFailure: onFailure)
    }

    private func getQuote(
        quoteRequest: TradeItQuotesRequest,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        self.marketDataService.getQuoteData(
            quoteRequest,
            withCompletionBlock: { result in
                if let quotesResult = result as? TradeItQuotesResult,
                    let quote = quotesResult.quotes?.first as? TradeItQuote {
                    onSuccess(quote)
                } else if let errorResult = result as? TradeItErrorResult {
                    onFailure(errorResult)
                } else {
                    onFailure(TradeItErrorResult(title: "Market Data failed", message: "Fetching the quote failed. Please try again later."))
                }
            }
        )
    }
}
