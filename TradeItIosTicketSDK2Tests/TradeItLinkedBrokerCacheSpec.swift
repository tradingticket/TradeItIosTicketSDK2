import Quick
import Nimble
import SwiftyUserDefaults
@testable import TradeItIosTicketSDK2

class TradeItLinkedBrokerCacheSpec: QuickSpec {
    var defaults = NSUserDefaults(suiteName: "TEST")!

    override func spec() {
        var cache: TradeItLinkedBrokerCache!
        var linkedLogin1: TradeItLinkedLogin!
        var linkedLogin2: TradeItLinkedLogin!
        var linkedBroker1: TradeItLinkedBroker!
        var linkedBroker2: TradeItLinkedBroker!

        beforeEach {
            // This doesn't work in the simulator.  Thanks, Apple.
            self.defaults.removeAll()

            // So we have to do this nonsense instead.
            self.defaults = NSUserDefaults(suiteName: "TEST \(NSDate().timeIntervalSince1970)")!

            expect(Defaults[.linkedBrokerCache]).to(beNil())

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

            let account1 = TradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker1,
                accountName: "My Special Account 1",
                accountNumber: "My Special Account Number 1",
                balance: nil,
                fxBalance: nil,
                positions: [])

            linkedBroker1.accounts.append(account1)

            let account2 = TradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker1,
                accountName: "My Special Account 2",
                accountNumber: "My Special Account Number 2",
                balance: nil,
                fxBalance: nil,
                positions: [])

            linkedBroker1.accounts.append(account2)

            let account3 = TradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker2,
                accountName: "My Special Account 3",
                accountNumber: "My Special Account Number 3",
                balance: nil,
                fxBalance: nil,
                positions: [])

            linkedBroker2.accounts.append(account3)
        }

        describe("cache(linkedBroker:)") {
            context("when the broker doesn't already exist in the cache") {
                beforeEach {
                    //////
                    let serializedBrokers = self.defaults[.linkedBrokerCache] as? TradeItLinkedBrokerCache.SerializedLinkedBrokers
                    print("=====> serializedBrokers BEFORE FIRST ADD: \(serializedBrokers)")
                    /////
                    cache.cache(linkedBroker: linkedBroker1)
                }

                it("adds the broker to the cache") {
                    let serializedBrokers = self.defaults[.linkedBrokerCache] as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                    print("=====> serializedBrokers AFTER FIRST ADD: \(serializedBrokers)")
                    expect(serializedBrokers.keys.count).to(equal(1))

                    let accounts = serializedBrokers["My Special User ID 1"] as! TradeItLinkedBrokerCache.SerializedLinkedBrokerAccounts!

                    expect(accounts.count).to(equal(2))

                    let serializedAccount1 = accounts["My Special Account Number 1"]!

                    expect(serializedAccount1["accountName"]!).to(equal("My Special Account 1"))

                    let serializedAccount2 = accounts["My Special Account Number 2"]!

                    expect(serializedAccount2["accountName"]!).to(equal("My Special Account 2"))
                }

                describe ("adding a subsequent linked broker") {
                    beforeEach {
                        cache.cache(linkedBroker: linkedBroker2)
                    }

                    it("adds it to the cache") {
                        let serializedBrokers = self.defaults[.linkedBrokerCache] as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                        print("=====> serializedBrokers AFTER SECOND ADD: \(serializedBrokers)")
                        expect(serializedBrokers.keys.count).to(equal(2))

                        let accounts1 = serializedBrokers["My Special User ID 1"] as! TradeItLinkedBrokerCache.SerializedLinkedBrokerAccounts!

                        expect(accounts1.count).to(equal(2))

                        let accounts2 = serializedBrokers["My Special User ID 2"] as! TradeItLinkedBrokerCache.SerializedLinkedBrokerAccounts!

                        expect(accounts2.count).to(equal(1))

                        let serializedAccount3 = accounts2["My Special Account Number 3"]!

                        expect(serializedAccount3["accountName"]!).to(equal("My Special Account 3"))
                    }
                }
            }

            context("when the broker already exists in the cache") {
                beforeEach {
                    cache.cache(linkedBroker: linkedBroker1)
                    cache.cache(linkedBroker: linkedBroker2)

                    let newAccount = TradeItLinkedBrokerAccount(
                        linkedBroker: linkedBroker1,
                        accountName: "My New Account",
                        accountNumber: "My New Account Number",
                        balance: nil,
                        fxBalance: nil,
                        positions: [])

                    linkedBroker1.accounts = [newAccount]

                    cache.cache(linkedBroker: linkedBroker1)
                }

                it("overwrites all of the broker's cached data") {
                    let serializedBrokers = self.defaults[.linkedBrokerCache] as! TradeItLinkedBrokerCache.SerializedLinkedBrokers

                    print("=====> serializedBrokers AFTER REWRITE: \(serializedBrokers)")
                    expect(serializedBrokers.keys.count).to(equal(2))

                    let accounts = serializedBrokers["My Special User ID 1"] as! TradeItLinkedBrokerCache.SerializedLinkedBrokerAccounts!

                    expect(accounts.count).to(equal(1))

                    let serializedAccount = accounts["My New Account Number"]!

                    expect(serializedAccount["accountName"]!).to(equal("My New Account"))
                }
            }
        }

        describe("syncFromCache(linkedBroker:)") {}

        describe("remove(linkedBroker:)") {}
    }
}
