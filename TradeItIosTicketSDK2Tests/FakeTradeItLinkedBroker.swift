@testable import TradeItIosTicketSDK2

class FakeTradeItLinkedBroker: TradeItLinkedBroker {

    let calls = SpyRecorder()

    init() {
        super.init(session: TradeItSession(), linkedLogin: TradeItLinkedLogin())
    }
    
    override init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        super.init(session: session, linkedLogin: linkedLogin)
    }

    override func authenticate(onSuccess: @escaping () -> Void,
                               onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                               _ submitAnswer: @escaping (String) -> Void,
                               _ onCancelSecurityQuestion: @escaping () -> Void) -> Void,
                               onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {
        self.calls.record(#function,
                          args: [
                            "onSuccess": onSuccess,
                            "onSecurityQuestion": onSecurityQuestion,
                            "onFailure": onFailure
            ])

    }

    override func refreshAccountBalances(onFinished: @escaping () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onFinished": onFinished
            ])
    }
}
