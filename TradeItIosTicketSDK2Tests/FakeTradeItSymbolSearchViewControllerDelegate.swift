
class FakeTradeItSymbolSearchViewControllerDelegate: TradeItSymbolSearchViewControllerDelegate {
    let calls = SpyRecorder()
    
    func symbolWasSelected(selectedSymbol: String) {
        self.calls.record(#function, args: [
                "selectedSymbol": selectedSymbol
            ])
    }
    
}
