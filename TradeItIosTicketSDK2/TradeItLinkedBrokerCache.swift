class TradeItLinkedBrokerCache {
    typealias UserId = String
    typealias AccountNumber = String
    typealias SerializedLinkedBroker = [String: Any]
    typealias SerializedLinkedBrokers = [UserId: SerializedLinkedBroker]
    typealias SerializedLinkedBrokerAccount = [String: String]
    typealias SerializedLinkedBrokerAccounts = [AccountNumber: SerializedLinkedBrokerAccount]

    private let ACCOUNTS_KEY = "ACCOUNTS"
    private let ACCOUNTS_LAST_UPDATED_KEY = "ACCOUNTS_LAST_UPDATED"
    private let ACCOUNT_NAME_KEY = "ACCOUNT_NAME"
    private let LINKED_BROKER_CACHE_KEY = "LINKED_BROKER_CACHE"

    var defaults = UserDefaults(suiteName: "it.trade")!

    func cache(linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId else { return }

        var linkedBrokerCache = defaults.dictionary(forKey: LINKED_BROKER_CACHE_KEY) as? SerializedLinkedBrokers ?? SerializedLinkedBrokers()

        let serializedLinkedBroker = serialize(linkedBroker: linkedBroker)

        linkedBrokerCache[userId] = serializedLinkedBroker

        defaults.set(linkedBrokerCache, forKey: LINKED_BROKER_CACHE_KEY)
    }

    func syncFromCache(linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId
            , let linkedBrokerCache = defaults.dictionary(forKey: LINKED_BROKER_CACHE_KEY) as? SerializedLinkedBrokers
            , let serializedLinkedBroker = linkedBrokerCache[userId] as SerializedLinkedBroker?
            else { return }

        if let serializedAccounts = serializedLinkedBroker[ACCOUNTS_KEY] as? SerializedLinkedBrokerAccounts {
            let accounts = deserialize(serializedAccounts: serializedAccounts,
                                       forLinkedBroker: linkedBroker)

            linkedBroker.accounts = accounts
        }

        linkedBroker.accountsLastUpdated = serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] as? Date
    }

    func remove(linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId
            , var linkedBrokerCache = defaults.dictionary(forKey: LINKED_BROKER_CACHE_KEY) as? SerializedLinkedBrokers
            else { return }

        linkedBrokerCache[userId] = nil
        defaults.set(linkedBrokerCache, forKey: LINKED_BROKER_CACHE_KEY)
    }

    // MARK: Private

    private func serialize(linkedBroker: TradeItLinkedBroker) -> SerializedLinkedBroker {
        var serializedLinkedBroker: SerializedLinkedBroker = [
            ACCOUNTS_KEY: serialize(accounts: linkedBroker.accounts)
        ]

        if let accountsLastUpdated = linkedBroker.accountsLastUpdated {
            serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] = accountsLastUpdated
        }

        return serializedLinkedBroker
    }

    private func deserialize(serializedAccounts: SerializedLinkedBrokerAccounts,
                             forLinkedBroker linkedBroker: TradeItLinkedBroker) -> [TradeItLinkedBrokerAccount] {
        return serializedAccounts.map { accountNumber, serializedAccount in
            return TradeItLinkedBrokerAccount(linkedBroker: linkedBroker,
                accountName: serializedAccount[ACCOUNT_NAME_KEY] ?? "",
                accountNumber: accountNumber,
                balance: nil,
                fxBalance: nil,
                positions: [])
        }
    }

    private func serialize(accounts: [TradeItLinkedBrokerAccount]) -> SerializedLinkedBrokerAccounts {
        var serializedAccounts = SerializedLinkedBrokerAccounts()

        for account in accounts {
            var serializedAccount = SerializedLinkedBrokerAccount()

            serializedAccount[ACCOUNT_NAME_KEY] = account.accountName

            serializedAccounts[account.accountNumber] = serializedAccount
        }

        return serializedAccounts
    }
}
