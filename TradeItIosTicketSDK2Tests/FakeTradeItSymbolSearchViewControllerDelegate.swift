class FakeTradeItSymbolSearchViewControllerDelegate: TradeItSymbolSearchViewControllerDelegate {
    let calls = SpyRecorder()
    
    func symbolSearchViewController(symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String) {
        self.calls.record(#function, args: [
            "symbolSearchViewController": symbolSearchViewController,
            "didSelectSymbol": selectedSymbol
        ])
    }

    func symbolSearchCancelled(forSymbolSearchViewController symbolSearchController: TradeItSymbolSearchViewController) {
        self.calls.record(#function, args: [
            "symbolSearchViewController": symbolSearchViewController
        ])
    }
}
