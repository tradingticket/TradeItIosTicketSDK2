import TradeItIosEmsApi

class FakeTradeItConnector: TradeItConnector {
    let calls = SpyRecorder()
    var tradeItLinkedLoginToReturn: TradeItLinkedLogin!
    var tradeItLinkedLoginArrayToReturn: [TradeItLinkedLogin] = []

    override func getAvailableBrokersWithCompletionBlock(completionBlock: (([TradeItBroker]?) -> Void)?) {
        self.calls.record(#function, args: [
            "completionBlock": completionBlock
        ])
    }
    
    override func linkBrokerWithAuthenticationInfo(authInfo: TradeItAuthenticationInfo!,
                                                   andCompletionBlock: ((TradeItResult!) -> Void)!) {
        self.calls.record(#function, args: [
            "authInfo": authInfo,
            "andCompletionBlock": andCompletionBlock
        ])
    }
    
    override func saveLinkToKeychain(link: TradeItAuthLinkResult!, withBroker broker: String!) -> TradeItLinkedLogin? {
        self.calls.record(#function, args: [
            "link": link,
            "broker": broker
        ])

        return tradeItLinkedLoginToReturn
    }
    
    override func getLinkedLogins() -> [AnyObject]? {
        self.calls.record(#function)
        return tradeItLinkedLoginArrayToReturn as [TradeItLinkedLogin]
    }
    
    override func updateLinkInKeychain(link: TradeItUpdateLinkResult!, withBroker broker: String!) -> TradeItLinkedLogin! {
        self.calls.record(#function, args: [
            "link": link,
            "broker": broker
        ])
        return tradeItLinkedLoginToReturn
    }
    
    override func updateUserToken(linkedLogin: TradeItLinkedLogin?, withAuthenticationInfo authInfo: TradeItAuthenticationInfo, andCompletionBlock: ((TradeItResult!) -> Void)!) {
            self.calls.record(#function, args: [
                "linkedLogin": linkedLogin,
                "authInfo": authInfo,
                "andCompletionBlock": andCompletionBlock
            ])
    }
}

