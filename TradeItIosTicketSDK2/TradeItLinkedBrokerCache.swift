import CryptoSwift

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
    private let ACCOUNT_BASE_CURRENCY_KEY = "ACCOUNT_BASE_CURRENCY"
    private let ACCOUNT_ENABLED_KEY = "ACCOUNT_ENABLED"
    private let ACCOUNTS_LINK_DELAY_ERROR_KEY = "ACCOUNTS_LINK_DELAY_ERROR"
    private let BALANCE_LAST_UPDATED_KEY = "BALANCE_LAST_UPDATED"
    private let BALANCE_BUYING_POWER_KEY = "BALANCE_BUYING_POWER"
    private let BALANCE_BUYING_POWER_LABEL_KEY = "BALANCE_BUYING_POWER_LABEL"
    private let FX_BALANCE_BUYING_POWER_KEY = "FX_BALANCE_BUYING_POWER"

    private let ACCOUNT_ENABLED_VALUE = "ENABLED"
    private let ACCOUNT_DISABLED_VALUE = "DISABLED"

    internal static var _userDefaults = UserDefaults(suiteName: "it.trade")!
    internal var userDefaults: UserDefaults {
        get {
            return TradeItLinkedBrokerCache._userDefaults
        }
    }
    
    private static let dateFormatter = DateFormatter()
    private static let numberFormatter = NumberFormatter()
    private static let TRADEIT_CRYPTO_UUID_KEY = "TRADEIT_CRYPTO_UUID_KEY"
    private var aesKey: AES!
    
    init() {
        TradeItLinkedBrokerCache.numberFormatter.maximumFractionDigits = 6
        TradeItLinkedBrokerCache.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss Z"
        guard let aesKey = self.getAesKey() else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItLinkedBrokerCache - unable to get an AES key.")
        }
        self.aesKey = aesKey
    }

    func cache(linkedBroker: TradeItLinkedBroker?) {
        guard let linkedBroker = linkedBroker, let userId = linkedBroker.linkedLogin.userId else { return }

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
        linkedBroker.isAccountLinkDelayedError = serializedLinkedBroker[ACCOUNTS_LINK_DELAY_ERROR_KEY] as? Bool ?? false
        if linkedBroker.isAccountLinkDelayedError {
            linkedBroker.error = TradeItErrorResult(title: "Activation In Progress", message: "Your \(linkedBroker.brokerName) is being activated. Check back soon (up to two business days)", code: TradeItErrorCode.accountNotAvailable)
        }
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
        return encryptData(isEnabled ? ACCOUNT_ENABLED_VALUE : ACCOUNT_DISABLED_VALUE)
    }

    private func serialize(linkedBroker: TradeItLinkedBroker) -> SerializedLinkedBroker {
        var serializedLinkedBroker: SerializedLinkedBroker = [
            ACCOUNTS_KEY: serialize(accounts: linkedBroker.accounts)
        ]

        if let accountsLastUpdated = linkedBroker.accountsLastUpdated {
            serializedLinkedBroker[ACCOUNTS_LAST_UPDATED_KEY] = accountsLastUpdated
        }
        
        serializedLinkedBroker[ACCOUNTS_LINK_DELAY_ERROR_KEY] = linkedBroker.isAccountLinkDelayedError
      
        return serializedLinkedBroker
    }

    private func deserialize(serializedAccounts: [SerializedLinkedBrokerAccount],
                             forLinkedBroker linkedBroker: TradeItLinkedBroker) -> [TradeItLinkedBrokerAccount] {

        return serializedAccounts.map { serializedAccount in
            var balanceLastUpdatedDate:Date? = nil
            
            switch serializedAccount[BALANCE_LAST_UPDATED_KEY] {
            case let balanceLastUpdated as Date:
                balanceLastUpdatedDate = balanceLastUpdated
            case let balanceLasUpdatedEncrypted as String:
                balanceLastUpdatedDate = TradeItLinkedBrokerCache.dateFormatter.date(from:decryptData(balanceLasUpdatedEncrypted))
            default:
                balanceLastUpdatedDate = nil
            }
        
            let account = TradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker,
                accountName: decryptData(serializedAccount[ACCOUNT_NAME_KEY] as? String  ?? ""),
                accountNumber: decryptData(serializedAccount[ACCOUNT_NUMBER_KEY]  as? String ?? ""),
                accountBaseCurrency: decryptData(serializedAccount[ACCOUNT_BASE_CURRENCY_KEY]  as? String ?? "USD"),
                balanceLastUpdated: balanceLastUpdatedDate,
                balance: nil,
                fxBalance: nil,
                positions: [],
                isEnabled: deserialize(accountEnabled: decryptData(serializedAccount[ACCOUNT_ENABLED_KEY] as? String))
            )

            var buyingPowerNumber:NSNumber? = nil
            switch serializedAccount[BALANCE_BUYING_POWER_KEY] {
            case let buyingPower as NSNumber:
                buyingPowerNumber = buyingPower
            case let buyingPowerEncrypted as String:
                buyingPowerNumber = TradeItLinkedBrokerCache.numberFormatter.number(from:decryptData(buyingPowerEncrypted))
            default:
                buyingPowerNumber = nil
            }
            
            if let buyingPower = buyingPowerNumber {
                let balance = TradeItAccountOverview()
                balance.buyingPower = buyingPower
                let buyingPowerLabel = decryptData(serializedAccount[BALANCE_BUYING_POWER_LABEL_KEY] as? String ?? "Buying Power")
                balance.buyingPowerLabel = buyingPowerLabel
                balance.accountBaseCurrency = account.accountBaseCurrency
                account.balance = balance
            }

            var fxBuyingPowerNumber:NSNumber? = nil
            switch serializedAccount[FX_BALANCE_BUYING_POWER_KEY] {
            case let fxBuyingPower as NSNumber:
                fxBuyingPowerNumber = fxBuyingPower
            case let fxBuyingPowerEncrypted as String:
                fxBuyingPowerNumber = TradeItLinkedBrokerCache.numberFormatter.number(from:decryptData(fxBuyingPowerEncrypted))
            default:
                fxBuyingPowerNumber = nil
            }
            
            if let fxBuyingPower = fxBuyingPowerNumber {
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
            serializedAccount[ACCOUNT_NAME_KEY] = encryptData(account.accountName)
            serializedAccount[ACCOUNT_NUMBER_KEY] = encryptData(account.accountNumber)
            serializedAccount[ACCOUNT_BASE_CURRENCY_KEY] = encryptData(account.accountBaseCurrency)
            serializedAccount[ACCOUNT_ENABLED_KEY] = encryptData(account.isEnabled ? ACCOUNT_ENABLED_VALUE : ACCOUNT_DISABLED_VALUE)

            if let balance = account.balance,
                let buyingPower = balance.buyingPower {

                if let balanceLastUpdated = account.balanceLastUpdated {
                    serializedAccount[BALANCE_LAST_UPDATED_KEY] = encryptData(TradeItLinkedBrokerCache.dateFormatter.string(from: balanceLastUpdated))
                }
                
                serializedAccount[BALANCE_BUYING_POWER_KEY] = encryptData(TradeItLinkedBrokerCache.numberFormatter.string(from: buyingPower))
                
                let buyingPowerLabel = balance.buyingPowerLabel ?? "Buying Power"
                serializedAccount[BALANCE_BUYING_POWER_LABEL_KEY] = encryptData(buyingPowerLabel)
            }

            if let fxBalance = account.fxBalance,
                let buyingPowerBaseCurrency = fxBalance.buyingPowerBaseCurrency {

                if let balanceLastUpdated = account.balanceLastUpdated {
                    serializedAccount[BALANCE_LAST_UPDATED_KEY] = encryptData(TradeItLinkedBrokerCache.dateFormatter.string(from: balanceLastUpdated))
                }

                serializedAccount[FX_BALANCE_BUYING_POWER_KEY] = encryptData(TradeItLinkedBrokerCache.numberFormatter.string(from: buyingPowerBaseCurrency))
            }

            serializeAccountsList.append(serializedAccount)
        }
        
        return serializeAccountsList
    }
    
    private func encryptData(_ data: String?) -> String {
        var encryptedData = data ?? ""
        do {
            if let data = data {
                encryptedData = try self.aesKey.encrypt(Array(data.utf8)).toBase64()!
            }
        } catch {
            print("===> ERROR encryptData: \(error)")
        }
        return encryptedData
    }
    
    private func decryptData(_ data: String?) -> String {
        var decryptedData = data ?? ""
        do {
            if let data = data {
                decryptedData = try data.decryptBase64ToString(cipher: self.aesKey)
            }
        } catch {
            print("===> ERROR decryptData: \(error)")
        }
        
        return decryptedData
    }
    
    private func getAesKey() -> AES? {
        print("(computing key \(Date())")
        let uuid = getUUID()
        let index = uuid.index(uuid.startIndex, offsetBy: 16)
        let salt: Array<UInt8> = Array(uuid.substring(to: index).utf8)
        var aes: AES?
        do {
            let cryptoKey = try PKCS5.PBKDF2(password: Array(uuid.utf8), salt: salt, iterations: 4096, variant: .sha256).calculate()
            print("(end computing key \(Date())")
            aes = try AES(key: cryptoKey)
        } catch {
            print("===> ERROR Creating cryptoKey: \(error)")
        }
        return aes
    }
    
    private func getUUID() -> String {
        if let uuid = TradeItKeychain.getStringForKey(TradeItLinkedBrokerCache.TRADEIT_CRYPTO_UUID_KEY) {
            return uuid
        } else {
            let newUUID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            TradeItKeychain.save(newUUID, forKey: TradeItLinkedBrokerCache.TRADEIT_CRYPTO_UUID_KEY)
            return newUUID
        }
    }
    
}
