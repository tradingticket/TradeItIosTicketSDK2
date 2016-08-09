class FakeTradeItConnector: TradeItConnector {
    let calls = InvocationStack()
    var tradeItLinkedLogin: TradeItLinkedLogin!

    override func getAvailableBrokersAsObjectsWithCompletionBlock(completionBlock: (([TradeItBroker]?) -> Void)) {
        self.calls.invoke(#function, args: completionBlock)
    }
    
    override func linkBrokerWithAuthenticationInfo(authInfo: TradeItAuthenticationInfo!,
                                                   andCompletionBlock: ((TradeItResult!) -> Void)!) {
        self.calls.invoke(#function, args: authInfo, andCompletionBlock)
    }
    
    override func saveLinkToKeychain(link: TradeItAuthLinkResult!, withBroker broker: String!) -> TradeItLinkedLogin! {
        self.calls.invoke(#function, args: link, broker)
        return tradeItLinkedLogin
    }
}

