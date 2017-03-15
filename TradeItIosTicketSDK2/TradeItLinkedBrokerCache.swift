class TradeItLinkedBrokerCache {
    typealias UserId = String
    typealias SerializedLinkedBroker = [String: Any]
    typealias SerializedLinkedBrokers = [UserId: SerializedLinkedBroker]
    typealias SerializedLinkedBrokerAccount = [String: Any]

    private let LINKED_BROKER_CACHE_KEY = "LINKED_BROKER_CACHE"

    private let ACCOUNTS_KEY = "ACCOUNTS"
    private let ACCOUNTS_LAST_UPDATED_KEY = "ACCOUNTS_LAST_UPDATED"
    private let ACCOUNT_NAME_KEY = "ACCOUNT_NAME"
    private let ACCOUNT_NUMBER_KEY = "ACCOUNT_NUMBER"
    private let ACCOUNT_ENABLED_KEY = "ACCOUNT_ENABLED"
    private let BALANCE_LAST_UPDATED_KEY = "BALANCE_LAST_UPDATED"
    private let BALANCE_BUYING_POWER_KEY = "BALANCE_BUYING_POWER"
    private let FX_BALANCE_BUYING_POWER_KEY = "FX_BALANCE_BUYING_POWER"

    private let ACCOUNT_ENABLED_VALUE = "ENABLED"
    private let ACCOUNT_DISABLED_VALUE = "DISABLED"

    internal static var _userDefaults = UserDefaults(suiteName: "it.trade")!
    internal var userDefaults: UserDefaults {
        get {
            return TradeItLinkedBrokerCache._userDefaults
        }
    }

    func cache(linkedBroker: TradeItLinkedBroker?) {
        guard let linkedBroker = linkedBroker, let userId = linkedBroker.linkedLogin.userId else { return }

        var linkedBrokerCache = userDefaults.dictionary(forKey: LINKED_BROKER_CACHE_KEY) as? SerializedLinkedBrokers ?? SerializedLinkedBrokers()

        // TODO: NEED TO RETAIN CACHED ACCOUNT BALANCES IF NO (OR OLDER) TIMESTAMP...
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

    // MARK: Debugging

    internal static func printCache() {
        print("=====> USER DEFAULTS VALUES: \(Array(UserDefaults(suiteName: "it.trade")!.dictionaryRepresentation().values))")
    }

    // MARK: Private

    private func deserialize(accountEnabled: String?) -> Bool {
        return accountEnabled != ACCOUNT_DISABLED_VALUE
    }

    private func serializeAccountEnabled(isEnabled: Bool) -> String {
        return isEnabled ? ACCOUNT_ENABLED_VALUE : ACCOUNT_DISABLED_VALUE
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
            let account = TradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker,
                accountName: serializedAccount[ACCOUNT_NAME_KEY] as? String  ?? "",
                accountNumber: serializedAccount[ACCOUNT_NUMBER_KEY]  as? String ?? "",
                balanceLastUpdated: serializedAccount[BALANCE_LAST_UPDATED_KEY] as? Date,
                balance: nil,
                fxBalance: nil,
                positions: [],
                isEnabled: deserialize(accountEnabled: serializedAccount[ACCOUNT_ENABLED_KEY] as? String)
            )

            if let buyingPower = serializedAccount[BALANCE_BUYING_POWER_KEY] as? NSNumber {
                let balance = TradeItAccountOverview()
                balance.buyingPower = buyingPower

                account.balance = balance
            }

            if let fxBuyingPower = serializedAccount[FX_BALANCE_BUYING_POWER_KEY] as? NSNumber {
                let fxBalance = TradeItFxAccountOverview()
                fxBalance.buyingPowerBaseCurrency = fxBuyingPower

                account.fxBalance = fxBalance
            }

            return account
        }
    }

    private func serialize(accounts: [TradeItLinkedBrokerAccount]) -> [SerializedLinkedBrokerAccount] {
        var serializeAccountsList: [SerializedLinkedBrokerAccount] = []
        for account in accounts {
            var serializedAccount = SerializedLinkedBrokerAccount()
            serializedAccount[ACCOUNT_NAME_KEY] = account.accountName
            serializedAccount[ACCOUNT_NUMBER_KEY] = account.accountNumber
            serializedAccount[ACCOUNT_ENABLED_KEY] = account.isEnabled ? ACCOUNT_ENABLED_VALUE : ACCOUNT_DISABLED_VALUE

            if let balance = account.balance,
                let buyingPower = balance.buyingPower {

                if let balanceLastUpdated = account.balanceLastUpdated {
                    serializedAccount[BALANCE_LAST_UPDATED_KEY] = balanceLastUpdated
                }

                serializedAccount[BALANCE_BUYING_POWER_KEY] = buyingPower
            }

            if let fxBalance = account.fxBalance,
                let buyingPowerBaseCurrency = fxBalance.buyingPowerBaseCurrency {

                if let balanceLastUpdated = account.balanceLastUpdated {
                    serializedAccount[BALANCE_LAST_UPDATED_KEY] = balanceLastUpdated
                }

                serializedAccount[FX_BALANCE_BUYING_POWER_KEY] = buyingPowerBaseCurrency
            }

            serializeAccountsList.append(serializedAccount)
        }
        
        return serializeAccountsList
    }
}
