import TradeItIosEmsApi

class FakeTradeItLinkedBroker: TradeItLinkedBroker {

    let calls = SpyRecorder()
    
    override init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        super.init(session: session, linkedLogin: linkedLogin)
    }
    
    override func authenticate(onSuccess onSuccess: () -> Void,
                                         onSecurityQuestion: (TradeItSecurityQuestionResult) -> String,
                                         onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.calls.record(#function,
                          args: [
                            "onSuccess": onSuccess,
                            "onSecurityQuestion": onSecurityQuestion,
                            "onFailure": onFailure
            ])

    }
}
