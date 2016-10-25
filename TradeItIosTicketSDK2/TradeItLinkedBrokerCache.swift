import SwiftyUserDefaults

// https://github.com/radex/SwiftyUserDefaults

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

//        linkedBroker.accountsLastUpdated = serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] ?? 0
    }

    func remove(linkedBroker linkedBroker: TradeItLinkedBroker) {
        guard let userId = linkedBroker.linkedLogin.userId
            , var linkedBrokerCache = defaults[.linkedBrokerCache] as? SerializedLinkedBrokers
            else { return }

        linkedBrokerCache[userId] = nil
    }

    // MARK: Private

    private func serialize(linkedBroker linkedBroker: TradeItLinkedBroker) -> SerializedLinkedBroker {
        return [
            ACCOUNTS_LAST_UPDATED_KEY: 0, // linkedBroker.accountsLastUpdated // NSDate().timeIntervalSince1970
            ACCOUNTS_KEY: serialize(accounts: linkedBroker.accounts)
        ]
    }

    private func deserialize(serializedAccounts serializedAccounts: SerializedLinkedBrokerAccounts,
                             forLinkedBroker linkedBroker: TradeItLinkedBroker) -> [TradeItLinkedBrokerAccount] {
        var accounts = [TradeItLinkedBrokerAccount]()

        for (accountNumber, serializedAccount) in serializedAccounts {
            let account = TradeItLinkedBrokerAccount(linkedBroker: linkedBroker,
                                                     accountName: serializedAccount[ACCOUNT_NAME_KEY] ?? "",
                                                     accountNumber: accountNumber,
                                                     balance: nil,
                                                     fxBalance: nil,
                                                     positions: [])
            accounts.append(account)
        }

        return accounts
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
