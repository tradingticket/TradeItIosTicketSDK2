import ObjectMapper

class TradeItLinkedBrokerCache {

    private let LINKED_BROKER_CACHE_KEY = "TRADE_IT_LINKED_BROKER_CACHE_"
  
    func cache(linkedBroker: TradeItLinkedBroker?) {
        guard let linkedBroker = linkedBroker else { return }
        let key = LINKED_BROKER_CACHE_KEY+linkedBroker.linkedLogin.userId
        
        let serializedLinkedBroker = SerializedLinkedBroker(linkedBroker: linkedBroker)
        TradeItKeychain.save(serializedLinkedBroker.toJSONString(), forKey: key)
        
        removeOldCache(linkedBroker: linkedBroker)
    }

    func syncFromCache(linkedBroker: TradeItLinkedBroker) {
        let key = LINKED_BROKER_CACHE_KEY+linkedBroker.linkedLogin.userId
        guard let json = TradeItKeychain.getStringForKey(key)
            , let serializedLinkedBroker = SerializedLinkedBroker(JSONString: json)
            else { return }

        linkedBroker.accounts = serializedLinkedBroker.accounts.map { serializedAccount in
            return TradeItLinkedBrokerAccount(
                            linkedBroker: linkedBroker,
                            accountName: serializedAccount.accountName,
                            accountNumber: serializedAccount.accountNumber,
                            accountIndex: serializedAccount.accountIndex,
                            accountBaseCurrency: serializedAccount.accountBaseCurrency ,
                            balanceLastUpdated: serializedAccount.balanceLastUpdated,
                            balance: serializedAccount.balance,
                            fxBalance: serializedAccount.fxBalance,
                            positions: [],
                            orderCapabilities: [],
                            isEnabled: serializedAccount.isEnabled
                        )
            
        }
        linkedBroker.accountsLastUpdated = serializedLinkedBroker.accountsLastUpdated
        linkedBroker.isAccountLinkDelayedError = serializedLinkedBroker.isAccountLinkDelayedError

        if linkedBroker.isAccountLinkDelayedError {
            linkedBroker.error = TradeItErrorResult(
                title: "Activation In Progress",
                message: "Your \(linkedBroker.brokerName) link is being activated which can take up to two business days. Check back soon.",
                code: TradeItErrorCode.accountNotAvailable
            )
        }
    }

    func remove(linkedBroker: TradeItLinkedBroker) {
        let key = LINKED_BROKER_CACHE_KEY+linkedBroker.linkedLogin.userId
        TradeItKeychain.deleteString(forKey: key)
    }

    // MARK: Private
    
    private func removeOldCache(linkedBroker: TradeItLinkedBroker) {
        if let userDefault = UserDefaults(suiteName: "it.trade") {
            userDefault.removeSuite(named: "it.trade")
            userDefault.synchronize()
        }
    }
}

private class SerializedLinkedBroker: Mappable {
    
    var accounts: [SerializedLinkedBrokerAccount] = []
    var accountsLastUpdated: Date?
    var isAccountLinkDelayedError: Bool = false
    
    init(linkedBroker: TradeItLinkedBroker) {
        self.accounts = linkedBroker.accounts.map { account in
            return SerializedLinkedBrokerAccount(linkedBrokerAccount: account)
        }
        self.accountsLastUpdated = linkedBroker.accountsLastUpdated
        self.isAccountLinkDelayedError = linkedBroker.isAccountLinkDelayedError
    }
    
    // MARK: implements Mappable protocol
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        accounts <- map["accounts"]
        accountsLastUpdated <- (map["accountsLastUpdated"], DateTransform())
        isAccountLinkDelayedError <- map["isAccountLinkDelayedError"]
    }
}

private class SerializedLinkedBrokerAccount: Mappable {

    var accountName = ""
    var accountNumber = ""
    var accountIndex = ""
    var accountBaseCurrency = ""
    var balanceLastUpdated: Date?
    var balance: TradeItAccountOverview?
    var fxBalance: TradeItFxAccountOverview?
    public var isEnabled: Bool = true
    
    init(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.accountNumber = linkedBrokerAccount.accountNumber
        self.accountName = linkedBrokerAccount.accountName
        self.accountBaseCurrency = linkedBrokerAccount.accountBaseCurrency
        self.isEnabled = linkedBrokerAccount.isEnabled
        self.balance = linkedBrokerAccount.balance
        self.fxBalance = linkedBrokerAccount.fxBalance
        self.balanceLastUpdated = linkedBrokerAccount.balanceLastUpdated
    }
    
    // MARK: implements Mappable protocol
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        accountNumber <- map["accountNumber"]
        accountName <- map["accountName"]
        accountBaseCurrency <- map["accountBaseCurrency"]
        isEnabled <- map["isEnabled"]
        balance <- map["balance"]
        fxBalance <- map["fxBalance"]
        balanceLastUpdated <- (map["balanceLastUpdated"], DateTransform())
    }

}

