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
        var error: JSONModelError? = nil;
        guard let json = TradeItKeychain.getStringForKey(key)
            else { return }
        
        let serializedLinkedBroker = SerializedLinkedBroker(string: json, error: &error)
        if let error = error {
            print("JSONModel conversion error")
            print("- Expected class: \(SerializedLinkedBroker.self)")
            print("- json: \(json)")
            print("- JSONModel error: \(error)")
            return
        } else if let serializedLinkedBroker = serializedLinkedBroker {
            linkedBroker.accounts = serializedLinkedBroker.accounts.map { serializedAccount in
                let account = TradeItLinkedBrokerAccount(
                    linkedBroker: linkedBroker,
                    accountName: serializedAccount.accountName,
                    accountNumber: serializedAccount.accountNumber,
                    accountIndex: serializedAccount.accountIndex,
                    accountBaseCurrency: serializedAccount.accountBaseCurrency ,
                    balanceLastUpdated: serializedAccount.balanceLastUpdated,
                    balance: nil,
                    fxBalance: nil,
                    positions: [],
                    orderCapabilities: [],
                    isEnabled: serializedAccount.isEnabled
                )
                if let balance = serializedAccount.balance {
                    account.balance = TradeItAccountOverview()
                    account.balance?.buyingPower = balance.buyingPower
                }
                
                if let fxBalance = serializedAccount.fxBalance {
                    account.fxBalance = TradeItFxAccountOverview()
                    account.fxBalance?.buyingPowerBaseCurrency = fxBalance.buyingPowerBaseCurrency
                }
                return account
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
        } else {
            print("JSONModel unknown error")
            print("- Expected class: \(SerializedLinkedBroker.self)")
            print("- json: \(json)")
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

extension SerializedLinkedBroker {
    
    convenience init(linkedBroker: TradeItLinkedBroker) {
        self.init()
        self.accounts = linkedBroker.accounts.map { account in
            return SerializedLinkedBrokerAccount(linkedBrokerAccount: account)
        }
        self.accountsLastUpdated = linkedBroker.accountsLastUpdated
        self.isAccountLinkDelayedError = linkedBroker.isAccountLinkDelayedError
    }
}

extension SerializedLinkedBrokerAccount {
    convenience init(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.init()
        self.accountNumber = linkedBrokerAccount.accountNumber
        self.accountName = linkedBrokerAccount.accountName
        self.accountBaseCurrency = linkedBrokerAccount.accountBaseCurrency
        self.accountIndex = linkedBrokerAccount.accountIndex
        self.isEnabled = linkedBrokerAccount.isEnabled
        self.balance = SerializedAccountOverview(balance: linkedBrokerAccount.balance)
        self.fxBalance = SerializedFxAccountOverview(fxBalance: linkedBrokerAccount.fxBalance)
        self.balanceLastUpdated = linkedBrokerAccount.balanceLastUpdated
    }
}

extension SerializedAccountOverview {
    convenience init(balance: TradeItAccountOverview?) {
        self.init()
        self.buyingPower = balance?.buyingPower
    }
}

extension SerializedFxAccountOverview {
    convenience init(fxBalance: TradeItFxAccountOverview?) {
        self.init()
        self.buyingPowerBaseCurrency = fxBalance?.buyingPowerBaseCurrency
    }
}


