import TradeItIosEmsApi

class FakeTradeItLinkedLoginManager: TradeItLinkedLoginManager {
    let calls = SpyRecorder()

    init() {
        super.init(connector: FakeTradeItConnector())
    }
    
    override func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                                      onSuccess: () -> Void,
                                      onSecurityQuestion: (TradeItSecurityQuestionResult) -> String,
                                      onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.calls.record(#function, args: [
            "authInfo": authInfo,
            "onSuccess": onSuccess,
            "onSecurityQuestion": onSecurityQuestion,
            "onFailure": onFailure
            ])
    }
}