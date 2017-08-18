class TradeItLinkedBrokerCache {

    private let LINKED_BROKER_CACHE_KEY = "TRADE_IT_LINKED_BROKER_CACHE_"
  
    func cache(linkedBroker: TradeItLinkedBroker?) {
        guard let linkedBroker = linkedBroker else { return }
        let key = LINKED_BROKER_CACHE_KEY+linkedBroker.linkedLogin.userId
        
        let cachedLinkedBroker = CachedLinkedBroker(linkedBroker: linkedBroker)
        TradeItKeychain.save(cachedLinkedBroker.toJSONString(), forKey: key)
        
        removeOldCache(linkedBroker: linkedBroker)
    }

    func syncFromCache(linkedBroker: TradeItLinkedBroker) {
        let key = LINKED_BROKER_CACHE_KEY+linkedBroker.linkedLogin.userId
        guard let json = TradeItKeychain.getStringForKey(key)
             ,let cachedLinkedBroker = TradeItResultTransformer.transform(targetClassType: CachedLinkedBroker.self, json: json)
            else { return}
        
        linkedBroker.accounts = cachedLinkedBroker.accounts.map { cachedAccount in
            let account = TradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker,
                accountName: cachedAccount.accountName,
                accountNumber: cachedAccount.accountNumber,
                accountIndex: cachedAccount.accountIndex,
                accountBaseCurrency: cachedAccount.accountBaseCurrency ,
                balanceLastUpdated: cachedAccount.balanceLastUpdated,
                balance: nil,
                fxBalance: nil,
                positions: [],
                orderCapabilities: [],
                isEnabled: cachedAccount.isEnabled
            )
            if let balance = cachedAccount.balance {
                account.balance = TradeItAccountOverview()
                account.balance?.buyingPower = balance.buyingPower
            }
            
            if let fxBalance = cachedAccount.fxBalance {
                account.fxBalance = TradeItFxAccountOverview()
                account.fxBalance?.buyingPowerBaseCurrency = fxBalance.buyingPowerBaseCurrency
            }
            return account
        }
        linkedBroker.accountsLastUpdated = cachedLinkedBroker.accountsLastUpdated
        linkedBroker.isAccountLinkDelayedError = cachedLinkedBroker.isAccountLinkDelayedError
        
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

extension CachedLinkedBroker {
    
    convenience init(linkedBroker: TradeItLinkedBroker) {
        self.init()
        self.accounts = linkedBroker.accounts.map { account in
            return CachedLinkedBrokerAccount(linkedBrokerAccount: account)
        }
        self.accountsLastUpdated = linkedBroker.accountsLastUpdated
        self.isAccountLinkDelayedError = linkedBroker.isAccountLinkDelayedError
    }
}

extension CachedLinkedBrokerAccount {
    convenience init(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.init()
        self.accountNumber = linkedBrokerAccount.accountNumber
        self.accountName = linkedBrokerAccount.accountName
        self.accountBaseCurrency = linkedBrokerAccount.accountBaseCurrency
        self.accountIndex = linkedBrokerAccount.accountIndex
        self.isEnabled = linkedBrokerAccount.isEnabled
        self.balance = CachedAccountOverview(balance: linkedBrokerAccount.balance)
        self.fxBalance = CachedFxAccountOverview(fxBalance: linkedBrokerAccount.fxBalance)
        self.balanceLastUpdated = linkedBrokerAccount.balanceLastUpdated
    }
}

extension CachedAccountOverview {
    convenience init(balance: TradeItAccountOverview?) {
        self.init()
        self.buyingPower = balance?.buyingPower
    }
}

extension CachedFxAccountOverview {
    convenience init(fxBalance: TradeItFxAccountOverview?) {
        self.init()
        self.buyingPowerBaseCurrency = fxBalance?.buyingPowerBaseCurrency
    }
}


