class FakeTradeItMarketService: TradeItMarketService {
    let calls = SpyRecorder()
    
    override func symbolLookup(searchText: String, onSuccess: ([TradeItSymbolLookupCompany]) -> Void, onFailure: (TradeItErrorResult) -> Void) {
        self.calls.record(#function, args: [
            "searchText": searchText,
            "onSuccess": onSuccess,
            "onFailure": onFailure
            ])
    }
}
