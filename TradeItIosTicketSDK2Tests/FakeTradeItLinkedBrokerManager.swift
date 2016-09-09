import TradeItIosEmsApi

class FakeTradeItLinkedBrokerManager: TradeItLinkedBrokerManager {
    let calls = SpyRecorder()

    var accountsToReturn: [TradeItLinkedBrokerAccount] = []
    
    init() {
        super.init(connector: FakeTradeItConnector())
    }
    
    override func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                                      onSuccess: (TradeItLinkedBroker) -> Void,
                                      onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.calls.record(#function,
                          args: [
                              "authInfo": authInfo,
                              "onSuccess": onSuccess,
                              "onFailure": onFailure
                          ])
    }

    override func getAvailableBrokers(onSuccess onSuccess: (availableBrokers: [TradeItBroker]) -> Void,
                                                onFailure: () -> Void) -> Void {
        self.calls.record(#function,
                          args: [
                            "onSuccess": onSuccess,
                            "onFailure": onFailure
                          ])
    }
    
    override func getAllAccounts() -> [TradeItLinkedBrokerAccount] {
        return accountsToReturn
    }

    override func authenticateAll(onSecurityQuestion onSecurityQuestion: (TradeItSecurityQuestionResult) -> String,
                                                     onFinished: () -> Void) {
        self.calls.record(#function,
                          args: [
                              "onSecurityQuestion": onSecurityQuestion,
                              "onFinished": onFinished
                          ])
    }

    override func refreshAccountBalances(onFinished onFinished: () -> Void) {
        self.calls.record(#function,
                          args: [
                              "onFinished": onFinished
                          ])
    }
}