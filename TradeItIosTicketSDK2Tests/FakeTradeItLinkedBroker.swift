import TradeItIosEmsApi

class FakeTradeItLinkedBroker: TradeItLinkedBroker {

    let calls = SpyRecorder()

    init() {
        super.init(session: TradeItSession(), linkedLogin: TradeItLinkedLogin())
    }
    
    override init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        super.init(session: session, linkedLogin: linkedLogin)
    }
    
    override func authenticate(onSuccess onSuccess: () -> Void,
                                         onSecurityQuestion: (TradeItSecurityQuestionResult, onSecurityQuestionAnswered: (String) -> Void) -> Void,
                                         onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.calls.record(#function,
                          args: [
                            "onSuccess": onSuccess,
                            "onSecurityQuestion": onSecurityQuestion,
                            "onFailure": onFailure
            ])

    }

    override func refreshAccountBalances(onFinished onFinished: () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onFinished": onFinished
            ])
    }
}
