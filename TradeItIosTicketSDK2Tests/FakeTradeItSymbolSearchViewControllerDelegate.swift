@testable import TradeItIosTicketSDK2

class FakeTradeItSymbolSearchViewControllerDelegate: TradeItSymbolSearchViewControllerDelegate {
    let calls = SpyRecorder()
    
    func symbolSearchViewController(_ symbolSearchViewController: TradeItSymbolSearchViewController, didSelectSymbol selectedSymbol: String) {
        self.calls.record(#function, args: [
            "symbolSearchViewController": symbolSearchViewController,
            "didSelectSymbol": selectedSymbol
            ])
    }
}
