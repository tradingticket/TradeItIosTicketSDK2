@testable import TradeItIosTicketSDK2

class FakeTradeItPortfolioPositionsTableViewManager: TradeItPortfolioPositionsTableViewManager {
    let calls = SpyRecorder()
    
    override func updatePositions(withPositions positions: [TradeItPortfolioPosition]) {
        self.calls.record(#function,
                          args: [
                            "withPositions": positions,
            ])
    }
}
