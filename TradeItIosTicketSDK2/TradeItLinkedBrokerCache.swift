import SwiftyUserDefaults

extension DefaultsKeys {
    static let linkedBrokerCache = DefaultsKey<NSDictionary?>("linkedBrokerCache")
}

class TradeItLinkedBrokerCache {
    typealias UserId = String
    typealias AccountNumber = String
    typealias SerializedLinkedBroker = [String: AnyObject]
    typealias SerializedLinkedBrokers = [UserId: SerializedLinkedBroker]
    typealias SerializedLinkedBrokerAccount = [String: String]
    typealias SerializedLinkedBrokerAccounts = [AccountNumber: SerializedLinkedBrokerAccount]

    private let ACCOUNTS_KEY = "ACCOUNTS"
    private let ACCOUNTS_LAST_UPDATED_KEY = "ACCOUNTS_LAST_UPDATED"
    private let ACCOUNT_NAME_KEY = "ACCOUNT_NAME"

    var defaults = NSUserDefaults(suiteName: "it.trade")!

    func cache(linkedBroker linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId else { return }

        var linkedBrokerCache = defaults[.linkedBrokerCache] as? SerializedLinkedBrokers ?? SerializedLinkedBrokers()

        let serializedLinkedBroker = serialize(linkedBroker: linkedBroker)

        linkedBrokerCache[userId] = serializedLinkedBroker

        defaults[.linkedBrokerCache] = linkedBrokerCache
    }

    func syncFromCache(linkedBroker linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId
            , let linkedBrokerCache = defaults[.linkedBrokerCache] as? SerializedLinkedBrokers
            , let serializedLinkedBroker = linkedBrokerCache[userId] as SerializedLinkedBroker?
            else { return }

        if let serializedAccounts = serializedLinkedBroker[ACCOUNTS_KEY] as? SerializedLinkedBrokerAccounts {
            let accounts = deserialize(serializedAccounts: serializedAccounts,
                                       forLinkedBroker: linkedBroker)

            linkedBroker.accounts = accounts
        }

        linkedBroker.accountsLastUpdated = serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] as? NSDate
    }

    func remove(linkedBroker linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId
            , var linkedBrokerCache = defaults[.linkedBrokerCache] as? SerializedLinkedBrokers
            else { return }

        linkedBrokerCache[userId] = nil
        defaults[.linkedBrokerCache] = linkedBrokerCache
    }

    // MARK: Private

    private func serialize(linkedBroker linkedBroker: TradeItLinkedBroker) -> SerializedLinkedBroker {
        var serializedLinkedBroker: SerializedLinkedBroker = [
            ACCOUNTS_KEY: serialize(accounts: linkedBroker.accounts)
        ]

        if let accountsLastUpdated = linkedBroker.accountsLastUpdated {
            serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] = accountsLastUpdated
        }

        return serializedLinkedBroker
    }

    private func deserialize(serializedAccounts serializedAccounts: SerializedLinkedBrokerAccounts,
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

    private func serialize(accounts accounts: [TradeItLinkedBrokerAccount]) -> SerializedLinkedBrokerAccounts {
        var serializedAccounts = SerializedLinkedBrokerAccounts()

        for account in accounts {
            var serializedAccount = SerializedLinkedBrokerAccount()

            serializedAccount[ACCOUNT_NAME_KEY] = account.accountName

            serializedAccounts[account.accountNumber] = serializedAccount
        }

        return serializedAccounts
    }
}
