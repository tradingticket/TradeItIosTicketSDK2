@testable import TradeItIosTicketSDK2

class FakeTradeItConnector: TradeItConnector {
    let calls = SpyRecorder()
    var tradeItLinkedLoginToReturn: TradeItLinkedLogin!
    var tradeItLinkedLoginArrayToReturn: [TradeItLinkedLogin] = []

    override func getAvailableBrokers(completionBlock: (([TradeItBroker]?) -> Void)?) {
        self.calls.record(#function, args: [
            "completionBlock": completionBlock
        ])
    }
    
    override func linkBroker(with authInfo: TradeItAuthenticationInfo!,
                             andCompletionBlock: ((TradeItResult?) -> Void)!) {
        self.calls.record(#function, args: [
            "authInfo": authInfo,
            "andCompletionBlock": andCompletionBlock
        ])
    }
    
    override func saveToKeychain(withLink link: TradeItAuthLinkResult!, withBroker broker: String!) -> TradeItLinkedLogin? {
        self.calls.record(#function, args: [
            "link": link,
            "broker": broker
        ])

        return tradeItLinkedLoginToReturn
    }
    
    override func getLinkedLogins() -> [Any]? {
        self.calls.record(#function)
        return tradeItLinkedLoginArrayToReturn as [TradeItLinkedLogin]
    }
    
    override func updateKeychain(withLink link: TradeItAuthLinkResult?, withBroker broker: String?) -> TradeItLinkedLogin? {
        self.calls.record(#function, args: [
            "link": link,
            "broker": broker
        ])
        return tradeItLinkedLoginToReturn
    }
    
    override func updateUserToken(_ linkedLogin: TradeItLinkedLogin?, authInfo: TradeItAuthenticationInfo?, andCompletionBlock completionBlock: ((TradeItResult?) -> Void)?) {
        self.calls.record(#function, args: [
            "linkedLogin": linkedLogin,
            "authInfo": authInfo,
            "andCompletionBlock": completionBlock
            ])
    }
}

