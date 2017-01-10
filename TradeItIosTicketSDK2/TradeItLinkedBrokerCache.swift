class TradeItLinkedBrokerCache {
    typealias UserId = String
    typealias SerializedLinkedBroker = [String: Any]
    typealias SerializedLinkedBrokers = [UserId: SerializedLinkedBroker]
    typealias SerializedLinkedBrokerAccount = [String: String]

    private let ACCOUNTS_KEY = "ACCOUNTS"
    private let ACCOUNTS_LAST_UPDATED_KEY = "ACCOUNTS_LAST_UPDATED"
    private let ACCOUNT_NAME_KEY = "ACCOUNT_NAME"
    private let ACCOUNT_NUMBER_KEY = "ACCOUNT_NUMBER"
    private let ACCOUNT_ENABLED_KEY = "ACCOUNT_ENABLED"
    private let LINKED_BROKER_CACHE_KEY = "LINKED_BROKER_CACHE"
    private let ACCOUNT_ENABLED = "ENABLED"
    private let ACCOUNT_DISABLED = "DISABLED"

    internal static var _userDefaults = UserDefaults(suiteName: "it.trade")!
    internal var userDefaults: UserDefaults {
        get {
            return TradeItLinkedBrokerCache._userDefaults
        }
    }

    func cache(linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId else { return }

        var linkedBrokerCache = userDefaults.dictionary(forKey: LINKED_BROKER_CACHE_KEY) as? SerializedLinkedBrokers ?? SerializedLinkedBrokers()

        let serializedLinkedBroker = serialize(linkedBroker: linkedBroker)

        linkedBrokerCache[userId] = serializedLinkedBroker

        self.userDefaults.set(linkedBrokerCache, forKey: LINKED_BROKER_CACHE_KEY)
    }

    func syncFromCache(linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId
            , let linkedBrokerCache = self.userDefaults.dictionary(forKey: LINKED_BROKER_CACHE_KEY) as? SerializedLinkedBrokers
            , let serializedLinkedBroker = linkedBrokerCache[userId] as SerializedLinkedBroker?
            else { return }

        if let serializedAccounts = serializedLinkedBroker[ACCOUNTS_KEY] as? [SerializedLinkedBrokerAccount] {
            let accounts = deserialize(serializedAccounts: serializedAccounts,
                                       forLinkedBroker: linkedBroker)

            linkedBroker.accounts = accounts
        }

        linkedBroker.accountsLastUpdated = serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] as? Date
    }

    func remove(linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId
            , var linkedBrokerCache = self.userDefaults.dictionary(forKey: LINKED_BROKER_CACHE_KEY) as? SerializedLinkedBrokers
            else { return }

        linkedBrokerCache[userId] = nil
        self.userDefaults.set(linkedBrokerCache, forKey: LINKED_BROKER_CACHE_KEY)
    }

    // MARK: Private

    private func deserialize(accountEnabled: String?) -> Bool {
        return accountEnabled != ACCOUNT_DISABLED
    }

    private func serializeAccountEnabled(isEnabled: Bool) -> String {
        return isEnabled ? ACCOUNT_ENABLED : ACCOUNT_DISABLED
    }

    private func serialize(linkedBroker: TradeItLinkedBroker) -> SerializedLinkedBroker {
        var serializedLinkedBroker: SerializedLinkedBroker = [
            ACCOUNTS_KEY: serialize(accounts: linkedBroker.accounts)
        ]

        if let accountsLastUpdated = linkedBroker.accountsLastUpdated {
            serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] = accountsLastUpdated
        }

        return serializedLinkedBroker
    }

    private func deserialize(serializedAccounts: [SerializedLinkedBrokerAccount],
                             forLinkedBroker linkedBroker: TradeItLinkedBroker) -> [TradeItLinkedBrokerAccount] {
        
        
        return serializedAccounts.map { serializedAccount in
            return TradeItLinkedBrokerAccount(linkedBroker: linkedBroker,
                                              accountName: serializedAccount[ACCOUNT_NAME_KEY] ?? "",
                                              accountNumber: serializedAccount[ACCOUNT_NUMBER_KEY] ?? "",
                                              balance: nil,
                                              fxBalance: nil,
                                              positions: [],
                                              isEnabled: deserialize(accountEnabled: serializedAccount[ACCOUNT_ENABLED_KEY]))
        }
    }

    private func serialize(accounts: [TradeItLinkedBrokerAccount]) -> [SerializedLinkedBrokerAccount] {
        var serializeAccountsList: [SerializedLinkedBrokerAccount] = []
        for account in accounts {
            var serializedAccount = SerializedLinkedBrokerAccount()
            serializedAccount[ACCOUNT_NAME_KEY] = account.accountName
            serializedAccount[ACCOUNT_NUMBER_KEY] = account.accountNumber
            serializedAccount[ACCOUNT_ENABLED_KEY] = account.isEnabled ? ACCOUNT_ENABLED : ACCOUNT_DISABLED
            serializeAccountsList.append(serializedAccount)
        }
        
        return serializeAccountsList
    }
}
