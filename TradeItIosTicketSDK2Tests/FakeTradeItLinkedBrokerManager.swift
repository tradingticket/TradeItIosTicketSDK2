class FakeTradeItLinkedBrokerManager: TradeItLinkedBrokerManager {
    let calls = SpyRecorder()

    var hackAccountsToReturn: [TradeItLinkedBrokerAccount] = []
    var hackLinkedBrokersInErrorToReturn : [TradeItLinkedBroker] = []

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
    
    override func relinkBroker(linkedBroker: TradeItLinkedBroker,
                               authInfo: TradeItAuthenticationInfo,
                               onSuccess: (TradeItLinkedBroker) -> Void,
                               onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.calls.record(#function,
                          args: [
                            "linkedBroker": linkedBroker,
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
        return hackAccountsToReturn
    }
    
    override func getAllEnabledAccounts() -> [TradeItLinkedBrokerAccount] {
        return hackAccountsToReturn
    }
    
    override func getAllLinkedBrokersInError() -> [TradeItLinkedBroker] {
        return hackLinkedBrokersInErrorToReturn
    }

    override func authenticateAll(onSecurityQuestion onSecurityQuestion: (TradeItSecurityQuestionResult, (String) -> Void) -> Void,
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
    
    override func unlinkBroker(linkedBroker: TradeItLinkedBroker) {
        self.calls.record(#function,
                          args: [
                            "linkedBroker": linkedBroker
                          ])
    }
}
