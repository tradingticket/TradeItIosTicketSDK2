class FakeTradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount {

    let calls = SpyRecorder()
    
    override func getAccountOverview(onFinished onFinished: () -> Void) {
        self.calls.record(#function, args: [
            "onFinished": onFinished
            ])
    }

}
