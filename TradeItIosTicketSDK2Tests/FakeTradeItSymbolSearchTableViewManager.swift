class FakeTradeItSymbolSearchTableViewManager: TradeItSymbolSearchTableViewManager {
    let calls = SpyRecorder()
    
    override func updateSymbolResults(withResults symbolResults: [TradeItSymbolLookupCompany]) {
        self.calls.record(#function, args: [
            "symbolResults": symbolResults,
            ])

    }
}
