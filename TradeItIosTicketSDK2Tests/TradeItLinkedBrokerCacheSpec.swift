import Quick
import Nimble
import Foundation
@testable import TradeItIosTicketSDK2

class TradeItLinkedBrokerCacheSpec: QuickSpec {
    var defaults = UserDefaults(suiteName: "it.trade")!

    private func getNewDate() -> Date {
        usleep(10000)
        return Date()
    }

    override func spec() {
        var cache: TradeItLinkedBrokerCache!
        var linkedLogin1: TradeItLinkedLogin!
        var linkedLogin2: TradeItLinkedLogin!
        var linkedBroker1: TradeItLinkedBroker!
        var linkedBroker2: TradeItLinkedBroker!
        var date1: Date!
        var date2: Date!

        describe("TradeItLinkedBrokerCache") {
            beforeEach {
                // This doesn't work in the simulator.  Thanks, Apple.
                // self.defaults.removeSuite(named: "TRADE IT TEST SUITE")

                // So we have to do this nonsense instead.
                self.defaults = UserDefaults(suiteName: "TEST \(Date().timeIntervalSince1970)")!

                expect(self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE")).to(beNil())

                cache = TradeItLinkedBrokerCache()
                cache.defaults = self.defaults

                linkedLogin1 = TradeItLinkedLogin(
                    label: "My Special Label 1",
                    broker: "My Special Broker 1",
                    userId: "My Special User ID 1",
                    andKeyChainId: "My Special Keychain ID 1")

                linkedLogin2 = TradeItLinkedLogin(
                    label: "My Special Label 2",
                    broker: "My Special Broker 2",
                    userId: "My Special User ID 2",
                    andKeyChainId: "My Special Keychain ID 2")

                linkedBroker1 = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: linkedLogin1)
                linkedBroker2 = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: linkedLogin2)

                date1 = self.getNewDate()
                date2 = self.getNewDate()

                linkedBroker1.accountsLastUpdated = date1
                linkedBroker2.accountsLastUpdated = date2

                let account1 = TradeItLinkedBrokerAccount(
                    linkedBroker: linkedBroker1,
                    accountName: "My Special Account Name 1",
                    accountNumber: "My Special Account Number 1",
                    balance: nil,
                    fxBalance: nil,
                    positions: [])

                linkedBroker1.accounts.append(account1)

                let account2 = TradeItLinkedBrokerAccount(
                    linkedBroker: linkedBroker1,
                    accountName: "My Special Account Name 2",
                    accountNumber: "My Special Account Number 2",
                    balance: nil,
                    fxBalance: nil,
                    positions: [])

                linkedBroker1.accounts.append(account2)

                let account3 = TradeItLinkedBrokerAccount(
                    linkedBroker: linkedBroker2,
                    accountName: "My Special Account Name 3",
                    accountNumber: "My Special Account Number 3",
                    balance: nil,
                    fxBalance: nil,
                    positions: [])

                linkedBroker2.accounts.append(account3)
            }

            describe("cache(linkedBroker:)") {
                context("when the broker doesn't already exist in the cache") {
                    beforeEach {
                        cache.cache(linkedBroker: linkedBroker1)
                    }

                    it("adds the broker to the cache") {
                        let serializedBrokers = self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE") as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                        expect(serializedBrokers.keys.count).to(equal(1))

                        let serializedBroker = serializedBrokers["My Special User ID 1"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                        expect(serializedBroker.keys.count).to(equal(2))

                        let cachedDate1 = serializedBroker["ACCOUNTS_LAST_UPDATED"]! as! Date
                        expect(cachedDate1.timeIntervalSince1970).to(equal(date1.timeIntervalSince1970))

                        let accounts = serializedBroker["ACCOUNTS"]! as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                        expect(accounts.count).to(equal(2))

                        let serializedAccount1 = accounts[0]

                        expect(serializedAccount1.keys.count).to(equal(2))
                        expect(serializedAccount1["ACCOUNT_NAME"]!).to(equal("My Special Account Name 1"))
                        expect(serializedAccount1["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 1"))


                        let serializedAccount2 = accounts[1]

                        expect(serializedAccount2.keys.count).to(equal(2))
                        expect(serializedAccount2["ACCOUNT_NAME"]!).to(equal("My Special Account Name 2"))
                        expect(serializedAccount2["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 2"))
                    }

                    describe ("adding a subsequent linked broker") {
                        beforeEach {
                            cache.cache(linkedBroker: linkedBroker2)
                        }

                        it("adds it to the cache") {
                            let serializedBrokers = self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE") as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                            expect(serializedBrokers.keys.count).to(equal(2))

                            let serializedBroker1 = serializedBrokers["My Special User ID 1"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                            expect(serializedBroker1.keys.count).to(equal(2))

                            let cachedDate1 = serializedBroker1["ACCOUNTS_LAST_UPDATED"]! as! Date
                            expect(cachedDate1.timeIntervalSince1970).to(equal(date1.timeIntervalSince1970))

                            let serializedBroker2 = serializedBrokers["My Special User ID 2"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                            expect(serializedBroker2.keys.count).to(equal(2))

                            let cachedDate2 = serializedBroker2["ACCOUNTS_LAST_UPDATED"]! as! Date
                            expect(cachedDate2.compare(date2)).to(equal(ComparisonResult.orderedSame))

                            let accounts1 = serializedBroker1["ACCOUNTS"] as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                            expect(accounts1.count).to(equal(2))

                            let accounts2 = serializedBroker2["ACCOUNTS"] as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                            expect(accounts2.count).to(equal(1))

                            let serializedAccount3 = accounts2[0]

                            expect(serializedAccount3.keys.count).to(equal(2))
                            expect(serializedAccount3["ACCOUNT_NAME"]!).to(equal("My Special Account Name 3"))
                            expect(serializedAccount3["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 3"))
                            
                        }
                    }
                }

                context("when the broker already exists in the cache") {
                    var newDate: Date!

                    beforeEach {
                        cache.cache(linkedBroker: linkedBroker1)
                        cache.cache(linkedBroker: linkedBroker2)

                        let newLinkedBroker = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: linkedLogin1)

                        let newAccount = TradeItLinkedBrokerAccount(
                            linkedBroker: linkedBroker1,
                            accountName: "My New Account Name",
                            accountNumber: "My New Account Number",
                            balance: nil,
                            fxBalance: nil,
                            positions: [])

                        newLinkedBroker.accounts = [newAccount]

                        newDate = self.getNewDate()
                        newLinkedBroker.accountsLastUpdated = newDate

                        cache.cache(linkedBroker: newLinkedBroker)
                    }

                    it("overwrites all of the broker's cached data") {
                        let serializedBrokers = self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE") as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                        expect(serializedBrokers.keys.count).to(equal(2))

                        let serializedBroker1 = serializedBrokers["My Special User ID 1"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                        expect(serializedBroker1.keys.count).to(equal(2))

                        let cachedDate1 = serializedBroker1["ACCOUNTS_LAST_UPDATED"]! as! Date
                        expect(cachedDate1.timeIntervalSince1970).to(equal(newDate.timeIntervalSince1970))

                        let accounts1 = serializedBroker1["ACCOUNTS"] as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                        expect(accounts1.count).to(equal(1))

                        let newSerializedAccount = accounts1[0]

                        expect(newSerializedAccount.keys.count).to(equal(2))
                        expect(newSerializedAccount["ACCOUNT_NAME"]!).to(equal("My New Account Name"))
                        expect(newSerializedAccount["ACCOUNT_NUMBER"]!).to(equal("My New Account Number"))
                        

                        let serializedBroker2 = serializedBrokers["My Special User ID 2"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                        expect(serializedBroker2.keys.count).to(equal(2))

                        let cachedDate2 = serializedBroker2["ACCOUNTS_LAST_UPDATED"]! as! Date
                        expect(cachedDate2.timeIntervalSince1970).to(equal(date2.timeIntervalSince1970))

                        let accounts2 = serializedBroker2["ACCOUNTS"] as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                        expect(accounts2.count).to(equal(1))

                        let serializedAccount3 = accounts2[0]

                        expect(serializedAccount3.keys.count).to(equal(2))
                        expect(serializedAccount3["ACCOUNT_NAME"]!).to(equal("My Special Account Name 3"))
                        expect(serializedAccount3["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 3"))
                        
                    }
                }
            }

            describe("syncFromCache(linkedBroker:)") {
                beforeEach {
                    cache.cache(linkedBroker: linkedBroker1)
                    cache.cache(linkedBroker: linkedBroker2)
                }

                context("when the linked broker is in the cache") {
                    var linkedBrokerToSync: TradeItLinkedBroker!

                    beforeEach {
                        linkedBrokerToSync = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: linkedLogin1)

                        let account1 = TradeItLinkedBrokerAccount(
                            linkedBroker: linkedBrokerToSync,
                            accountName: "My Original Account Name",
                            accountNumber: "My Original Account Number",
                            balance: nil,
                            fxBalance: nil,
                            positions: [])
                        
                        linkedBrokerToSync.accounts.append(account1)

                        linkedBrokerToSync.accountsLastUpdated = self.getNewDate()

                        cache.syncFromCache(linkedBroker: linkedBrokerToSync)
                    }

                    it("should update the synced broker") {
                        expect(linkedBrokerToSync.accountsLastUpdated!.timeIntervalSince1970).to(equal(date1.timeIntervalSince1970))

                        let syncedAccounts = linkedBrokerToSync.accounts

                        expect(syncedAccounts.count).to(equal(2))

                        let syncedAccount1 = syncedAccounts.filter { (account) -> Bool in
                            return account.accountNumber == "My Special Account Number 1"
                        }.first

                        expect(syncedAccount1?.accountName).to(equal("My Special Account Name 1"))

                        let syncedAccount2 = syncedAccounts.filter { (account) -> Bool in
                            return account.accountNumber == "My Special Account Number 2"
                        }.first

                        expect(syncedAccount2?.accountName).to(equal("My Special Account Name 2"))
                    }

                    it("doesn't alter the cached brokers") {
                        let serializedBrokers = self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE") as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                        expect(serializedBrokers.keys.count).to(equal(2))

                        let serializedBroker1 = serializedBrokers["My Special User ID 1"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                        expect(serializedBroker1.keys.count).to(equal(2))

                        let cachedDate1 = serializedBroker1["ACCOUNTS_LAST_UPDATED"]! as! Date
                        expect(cachedDate1.timeIntervalSince1970).to(equal(date1.timeIntervalSince1970))

                        let serializedAccounts1 = serializedBroker1["ACCOUNTS"]! as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                        expect(serializedAccounts1.count).to(equal(2))

                        let serializedAccount1 = serializedAccounts1[0]

                        expect(serializedAccount1.keys.count).to(equal(2))
                        expect(serializedAccount1["ACCOUNT_NAME"]!).to(equal("My Special Account Name 1"))
                        expect(serializedAccount1["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 1"))

                        let serializedAccount2 = serializedAccounts1[1]

                        expect(serializedAccount2.keys.count).to(equal(2))
                        expect(serializedAccount2["ACCOUNT_NAME"]!).to(equal("My Special Account Name 2"))
                        expect(serializedAccount2["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 2"))

                        let serializedBroker2 = serializedBrokers["My Special User ID 2"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                        expect(serializedBroker2.keys.count).to(equal(2))

                        let cachedDate2 = serializedBroker2["ACCOUNTS_LAST_UPDATED"]! as! Date
                        expect(cachedDate2.timeIntervalSince1970).to(equal(date2.timeIntervalSince1970))

                        let serializedAccounts2 = serializedBroker2["ACCOUNTS"] as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                        expect(serializedAccounts2.count).to(equal(1))

                        let serializedAccount3 = serializedAccounts2[0]

                        expect(serializedAccount3.keys.count).to(equal(2))
                        expect(serializedAccount3["ACCOUNT_NAME"]!).to(equal("My Special Account Name 3"))
                        expect(serializedAccount3["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 3"))
                        
                    }
                }

                context("when the linked broker is not in the cache") {
                    var linkedBrokerToSync: TradeItLinkedBroker!
                    var originalDate: Date!

                    beforeEach {
                        let uncachedLinkedLogin = TradeItLinkedLogin(
                            label: "My Special Label 1",
                            broker: "My Special Broker 1",
                            userId: "My Uncached User ID",
                            andKeyChainId: "My Special Keychain ID 1")

                        linkedBrokerToSync = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: uncachedLinkedLogin)

                        let account1 = TradeItLinkedBrokerAccount(
                            linkedBroker: linkedBrokerToSync,
                            accountName: "My Original Account Name",
                            accountNumber: "My Original Account Number",
                            balance: nil,
                            fxBalance: nil,
                            positions: [])

                        linkedBrokerToSync.accounts.append(account1)

                        originalDate = self.getNewDate()
                        linkedBrokerToSync.accountsLastUpdated = originalDate

                        cache.syncFromCache(linkedBroker: linkedBrokerToSync)
                    }

                    it("doesn't alter the synced broker") {
                        expect(linkedBrokerToSync.accountsLastUpdated!.timeIntervalSince1970).to(equal(originalDate.timeIntervalSince1970))

                        let syncedAccounts = linkedBrokerToSync.accounts

                        expect(syncedAccounts.count).to(equal(1))

                        let syncedAccount1 = syncedAccounts.filter { (account) -> Bool in
                            return account.accountNumber == "My Original Account Number"
                        }.first

                        expect(syncedAccount1?.accountName).to(equal("My Original Account Name"))
                    }

                    it("doesn't alter the cached brokers") {
                        let serializedBrokers = self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE") as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                        expect(serializedBrokers.keys.count).to(equal(2))

                        let serializedBroker1 = serializedBrokers["My Special User ID 1"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                        expect(serializedBroker1.keys.count).to(equal(2))

                        let cachedDate1 = serializedBroker1["ACCOUNTS_LAST_UPDATED"]! as! Date
                        expect(cachedDate1.timeIntervalSince1970).to(equal(date1.timeIntervalSince1970))

                        let serializedAccounts1 = serializedBroker1["ACCOUNTS"]! as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                        expect(serializedAccounts1.count).to(equal(2))

                        let serializedAccount1 = serializedAccounts1[0]

                        expect(serializedAccount1.keys.count).to(equal(2))
                        expect(serializedAccount1["ACCOUNT_NAME"]!).to(equal("My Special Account Name 1"))
                        expect(serializedAccount1["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 1"))

                        let serializedAccount2 = serializedAccounts1[1]

                        expect(serializedAccount2.keys.count).to(equal(2))
                        expect(serializedAccount2["ACCOUNT_NAME"]!).to(equal("My Special Account Name 2"))
                        expect(serializedAccount2["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 2"))

                        let serializedBroker2 = serializedBrokers["My Special User ID 2"]! as TradeItLinkedBrokerCache.SerializedLinkedBroker

                        expect(serializedBroker2.keys.count).to(equal(2))

                        let cachedDate2 = serializedBroker2["ACCOUNTS_LAST_UPDATED"]! as! Date
                        expect(cachedDate2.timeIntervalSince1970).to(equal(date2.timeIntervalSince1970))

                        let serializedAccounts2 = serializedBroker2["ACCOUNTS"] as! [TradeItLinkedBrokerCache.SerializedLinkedBrokerAccount]

                        expect(serializedAccounts2.count).to(equal(1))

                        let serializedAccount3 = serializedAccounts2[0]
                        
                        expect(serializedAccount3.keys.count).to(equal(2))
                        expect(serializedAccount3["ACCOUNT_NAME"]!).to(equal("My Special Account Name 3"))
                        expect(serializedAccount3["ACCOUNT_NUMBER"]!).to(equal("My Special Account Number 3"))
                    }
                }
            }

            describe("remove(linkedBroker:)") {
                beforeEach {
                    cache.cache(linkedBroker: linkedBroker1)
                    cache.cache(linkedBroker: linkedBroker2)
                }

                context("when the linked broker is in the cache") {
                    var linkedBrokerToRemove: TradeItLinkedBroker!

                    beforeEach {
                        linkedBrokerToRemove = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: linkedLogin1)

                        let account1 = TradeItLinkedBrokerAccount(
                            linkedBroker: linkedBrokerToRemove,
                            accountName: "My Original Account Name",
                            accountNumber: "My Original Account Number",
                            balance: nil,
                            fxBalance: nil,
                            positions: [])

                        linkedBrokerToRemove.accounts.append(account1)

                        cache.remove(linkedBroker: linkedBrokerToRemove)
                    }

                    it("removes only the matching linked broker") {
                        let serializedBrokers = self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE") as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                        expect(serializedBrokers.keys.count).to(equal(1))
                        expect(serializedBrokers["My Special User ID 1"]).to(beNil())
                        expect(serializedBrokers["My Special User ID 2"]).notTo(beNil())
                    }
                }

                context("when the linked broker is not in the cache") {
                    var linkedBrokerToRemove: TradeItLinkedBroker!

                    beforeEach {
                        let uncachedLinkedLogin = TradeItLinkedLogin(
                            label: "My Special Label 1",
                            broker: "My Special Broker 1",
                            userId: "My Uncached User ID",
                            andKeyChainId: "My Special Keychain ID 1")

                        linkedBrokerToRemove = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: uncachedLinkedLogin)

                        let account1 = TradeItLinkedBrokerAccount(
                            linkedBroker: linkedBrokerToRemove,
                            accountName: "My Original Account Name",
                            accountNumber: "My Original Account Number",
                            balance: nil,
                            fxBalance: nil,
                            positions: [])

                        linkedBrokerToRemove.accounts.append(account1)

                        cache.remove(linkedBroker: linkedBrokerToRemove)
                    }

                    it("doesn't remove any linked brokers") {
                        let serializedBrokers = self.defaults.dictionary(forKey: "LINKED_BROKER_CACHE") as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                        expect(serializedBrokers.keys.count).to(equal(2))
                        expect(serializedBrokers["My Special User ID 1"]).notTo(beNil())
                        expect(serializedBrokers["My Special User ID 2"]).notTo(beNil())
                    }
                }
            }
        }
    }
}
