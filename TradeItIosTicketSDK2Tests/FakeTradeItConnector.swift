class FakeTradeItConnector: TradeItConnector {
    let calls = InvocationStack()
    var tradeItLinkedLogin: TradeItLinkedLogin!
    var completionBlockAvailableBrokers: (([AnyObject]!) -> Void)!
    var completionBlockLinkBrokerWithAuthenticationInfo: ((TradeItResult!) -> Void)!
    
    
    override func getAvailableBrokersWithCompletionBlock(completionBlock: (([AnyObject]!) -> Void)!) {
        calls.invoke(#function, args: completionBlock)
        self.completionBlockAvailableBrokers = completionBlock
    }
    
    override func linkBrokerWithAuthenticationInfo(authInfo: TradeItAuthenticationInfo!, andCompletionBlock: ((TradeItResult!) -> Void)!) {
        calls.invoke(#function, args: andCompletionBlock)
        self.completionBlockLinkBrokerWithAuthenticationInfo = andCompletionBlock
    }
    
    override func saveLinkToKeychain(link: TradeItAuthLinkResult!, withBroker broker: String!) -> TradeItLinkedLogin! {
        return tradeItLinkedLogin
    }
    
}