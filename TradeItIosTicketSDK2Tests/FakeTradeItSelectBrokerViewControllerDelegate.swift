@testable import TradeItIosTicketSDK2

class FakeTradeItSelectBrokerViewControllerDelegate: TradeItSelectBrokerViewControllerDelegate {
    let calls = SpyRecorder()
    
    func brokerWasSelected(fromSelectBrokerViewController: TradeItSelectBrokerViewController, broker: TradeItBroker) {
        self.calls.record(#function, args: [
                "fromSelectBrokerViewController": fromSelectBrokerViewController,
                "broker": broker
            ])
    }
    
    func cancelWasTapped(fromSelectBrokerViewController selectBrokerViewController: TradeItSelectBrokerViewController) {
        self.calls.record(#function, args: [
                "fromSelectBrokerViewController": selectBrokerViewController
            ])
    }
}
