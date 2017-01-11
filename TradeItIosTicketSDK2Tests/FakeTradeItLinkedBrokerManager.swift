@testable import TradeItIosTicketSDK2

class FakeTradeItLinkedBrokerManager: TradeItLinkedBrokerManager {
    let calls = SpyRecorder()

    var hackAccountsToReturn: [TradeItLinkedBrokerAccount] = []
    var hackLinkedBrokersInErrorToReturn : [TradeItLinkedBroker] = []

    init() {
        super.init(apiKey: "My test api key", environment: TradeItEmsTestEnv)
    }
    
    override func linkBroker(
        authInfo: TradeItAuthenticationInfo,
        onSuccess: @escaping (TradeItLinkedBroker) -> Void,
        onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {

        self.calls.record(#function,
                          args: [
                              "authInfo": authInfo,
                              "onSuccess": onSuccess,
                              "onSecurityQuestion": onSecurityQuestion,
                              "onFailure": onFailure
                          ])
    }
    
    override func relinkBroker(
        _ linkedBroker: TradeItLinkedBroker,
        authInfo: TradeItAuthenticationInfo,
        onSuccess: @escaping (TradeItLinkedBroker) -> Void,
        onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
            _ submitAnswer: @escaping (String) -> Void,
            _ onCancelSecurityQuestion: @escaping () -> Void) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void) -> Void {

        self.calls.record(#function,
                          args: [
                            "linkedBroker": linkedBroker,
                            "authInfo": authInfo,
                            "onSuccess": onSuccess,
                            "onSecurityQuestion": onSecurityQuestion,
                            "onFailure": onFailure
            ])
    }

    override func getAvailableBrokers(onSuccess: @escaping (_ availableBrokers: [TradeItBroker]) -> Void,
                                                onFailure: @escaping () -> Void) -> Void {
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

    override func authenticateAll(onSecurityQuestion: @escaping (TradeItSecurityQuestionResult,
                                                                _ submitAnswer: @escaping (String) -> Void,
                                                                _ onCancelSecurityQuestion: @escaping () -> Void) -> Void,
                    onFailure: @escaping (TradeItErrorResult, TradeItLinkedBroker) -> Void = {_ in },
                    onFinished: @escaping () -> Void) {
        self.calls.record(#function,
                          args: [
                              "onSecurityQuestion": onSecurityQuestion,
                              "onFailure": onFailure,
                              "onFinished": onFinished
                          ])
    }

    override func refreshAccountBalances(onFinished: @escaping () -> Void) {
        self.calls.record(#function,
                          args: [
                              "onFinished": onFinished
                          ])
    }
    
    override func unlinkBroker(_ linkedBroker: TradeItLinkedBroker) {
        self.calls.record(#function,
                          args: [
                            "linkedBroker": linkedBroker
                          ])
    }
}
