import TradeItIosEmsApi

class TradeItLinkedLoginManager {
    func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                             onSuccess: () -> Void,
                             onFailure: (TradeItErrorResult) -> Void) -> Void {}
}

class FakeTradeItLinkedLoginManager: TradeItLinkedLoginManager {
    let calls = SpyRecorder()

    override func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                                      onSuccess: () -> Void,
                                      onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.calls.record(#function, args: [
            "authInfo": authInfo,
            "onSuccess": onSuccess,
            "onFailure": onFailure
            ])
    }
}