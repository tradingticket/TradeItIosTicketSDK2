class FakeTradeItBrokerManagementTableViewManager: TradeItBrokerManagementTableViewManager {
    let calls = SpyRecorder()
    
    override func updateLinkedBrokers(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker]) {
        self.calls.record(#function,
                          args: [
                            "withLinkedBrokers": linkedBrokers,
            ])
    }
}
