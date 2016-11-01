@testable import TradeItIosTicketSDK2

class FakeTradeItMarketService: TradeItMarketService {
    let calls = SpyRecorder()
    
    override func symbolLookup(_ searchText: String, onSuccess: @escaping ([TradeItSymbolLookupCompany]) -> Void, onFailure: @escaping (TradeItErrorResult) -> Void) {
        self.calls.record(#function, args: [
            "searchText": searchText,
            "onSuccess": onSuccess,
            "onFailure": onFailure
            ])
    }
}
