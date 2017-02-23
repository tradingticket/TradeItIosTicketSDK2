import UIKit
@testable import TradeItIosTicketSDK2

class FakeTradeItPortfolioErrorHandlingViewManager: TradeItPortfolioErrorHandlingViewManager {

    let calls = SpyRecorder()
    
    override func showErrorHandlingView(withLinkedBrokerInError linkedBrokerInError: TradeItLinkedBroker?) {
        self.calls.record(#function, args: [
                "linkedBrokerInError": linkedBrokerInError
            ])
    }
}
