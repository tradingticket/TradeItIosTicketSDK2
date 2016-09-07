import Quick
import Nimble
@testable import TradeItIosEmsApi

class TradeItLinkedBrokerManagerSpec: QuickSpec {
    override func spec() {
        var linkedBrokerManager: TradeItLinkedBrokerManager!
        var tradeItConnector: FakeTradeItConnector! = FakeTradeItConnector()
        var tradeItSession: FakeTradeItSession!
        var tradeItSessionProvider: FakeTradeItSessionProvider!

        beforeEach {
            tradeItConnector = FakeTradeItConnector()
            tradeItSession = FakeTradeItSession()
            tradeItSessionProvider = FakeTradeItSessionProvider()
            tradeItSessionProvider.tradeItSessionToProvide = tradeItSession

            linkedBrokerManager = TradeItLinkedBrokerManager(connector: tradeItConnector)
            linkedBrokerManager.tradeItSessionProvider = tradeItSessionProvider
        }

        describe("getAvailableBrokers") {
            var onSuccessCallbackWasCalled = 0
            var onFailureCallbackWasCalled = 0

            var returnedBrokers: [TradeItBroker]!

            beforeEach {
                onSuccessCallbackWasCalled = 0
                onFailureCallbackWasCalled = 0
                returnedBrokers = nil


                linkedBrokerManager.getAvailableBrokers(
                    onSuccess: { (availableBrokers: [TradeItBroker]) -> Void in
                        onSuccessCallbackWasCalled += 1
                        returnedBrokers = availableBrokers
                    },
                    onFailure: { () -> Void in
                        onFailureCallbackWasCalled += 1
                    }
                )
            }

            it("gets the list of available brokers from the connector") {
                expect(tradeItConnector.calls.count).to(equal(1))
                let getBrokersCalls = tradeItConnector.calls.forMethod("getAvailableBrokersWithCompletionBlock")
                expect(getBrokersCalls.count).to(equal(1))
            }

            context("when getting available brokers succeeds") {
                var brokersResult: [TradeItBroker]!

                beforeEach {
                    brokersResult = [
                        TradeItBroker.init(shortName: "My Special Short Name",
                                           longName: "My Special Long Name")
                    ]

                    let getBrokersCalls = tradeItConnector.calls.forMethod("getAvailableBrokersWithCompletionBlock")
                    let completionBlock = getBrokersCalls[0].args["completionBlock"] as! ([TradeItBroker]?) -> Void

                    completionBlock(brokersResult)
                }

                it("passes the brokers to onSuccess") {
                    expect(onSuccessCallbackWasCalled).to(equal(1))
                    expect(onFailureCallbackWasCalled).to(equal(0))
                    expect(returnedBrokers).to(equal(brokersResult))
                }
            }

            context("when getting available brokers fails") {
                beforeEach {
                    let getBrokersCalls = tradeItConnector.calls.forMethod("getAvailableBrokersWithCompletionBlock")
                    let completionBlock = getBrokersCalls[0].args["completionBlock"] as! ([TradeItBroker]?) -> Void

                    completionBlock(nil)
                }

                it("calls onFailure") {
                    expect(onSuccessCallbackWasCalled).to(equal(0))
                    expect(onFailureCallbackWasCalled).to(equal(1))
                }
            }
        }

        describe("linkBroker") {
            var onSuccessCallbackWasCalled = 0
            var onFailureCallbackWasCalled = 0

            var returnedLinkedBroker: TradeItLinkedBroker! = nil
            var returnedErrorResult: TradeItErrorResult! = nil


            beforeEach {
                onSuccessCallbackWasCalled = 0
                onFailureCallbackWasCalled = 0

                let authInfo = TradeItAuthenticationInfo(id: "My Special Username",
                                                         andPassword: "My Special Password",
                                                         andBroker: "My Special Broker")

                linkedBrokerManager.linkBroker(
                    authInfo: authInfo,
                    onSuccess: { (linkedBroker: TradeItLinkedBroker) -> Void in
                        onSuccessCallbackWasCalled += 1
                        returnedLinkedBroker = linkedBroker
                    },
                    onFailure: { (tradeItErrorResult: TradeItErrorResult) in
                        onFailureCallbackWasCalled += 1
                        returnedErrorResult = tradeItErrorResult
                    }
                )
            }

            it("links the broker with the connector") {
                expect(tradeItConnector.calls.count).to(equal(1))
                let linkCalls = tradeItConnector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")
                expect(linkCalls.count).to(equal(1))
            }

            context("when linking succeeds") {
                let linkResult = TradeItAuthLinkResult()
                let linkedLogin = TradeItLinkedLogin()
                linkedLogin.broker = "My broker #1"

                beforeEach {
                    tradeItConnector.tradeItLinkedLoginToReturn = linkedLogin

                    let linkCalls = tradeItConnector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")
                    let completionBlock = linkCalls[0].args["andCompletionBlock"] as! (TradeItResult!) -> Void

                    completionBlock(linkResult)
                }

                it("should save the linkedLogin to the Keychain") {
                    let saveLinkToKeychainCalls = tradeItConnector.calls.forMethod("saveLinkToKeychain(_:withBroker:)")
                    expect(saveLinkToKeychainCalls.count).to(equal(1))

                    let linkResultArg = saveLinkToKeychainCalls[0].args["link"] as! TradeItAuthLinkResult
                    expect(linkResultArg).to(be(linkResult))

                    let brokerArg = saveLinkToKeychainCalls[0].args["broker"] as! String
                    expect(brokerArg).to(equal("My Special Broker"))
                }

                it("calls the onSuccess callback with the linkedBroker") {
                    expect(onSuccessCallbackWasCalled).to(equal(1))
                    expect(onFailureCallbackWasCalled).to(equal(0))

                    expect(returnedLinkedBroker.session).to(be(tradeItSession))
                    expect(returnedLinkedBroker.linkedLogin).to(be(linkedLogin))
                }

//                it("should authenticate with the session") {
//                    let authenticateCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
//
//                    expect(tradeItSession.calls.count).to(equal(1))
//                    expect(authenticateCalls.count).to(equal(1))
//                    expect(authenticateCalls[0].args["linkedLogin"] as! TradeItLinkedLogin).to(be(linkedLogin))
//                }
//
//                context("when authentication fails") {
//                    beforeEach {
//                        let tradeItErrorResult = TradeItErrorResult()
//                        let linkCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
//                        let completionBlock = linkCalls[0].args["withCompletionBlock"] as! (TradeItResult!) -> Void
//
//                        completionBlock(tradeItErrorResult)
//                    }
//
//                    it("should call the onFailure callback and return a TradeItErrorResult") {
//                        expect(onSuccessCallbackWasCalled).to(equal(0))
//                        expect(onSecurityQuestionCallbackWasCalled).to(equal(0))
//                        expect(onFailureCallbackWasCalled).to(equal(1))
//
//                        expect(returnedTradeItResult).to(beAnInstanceOf(TradeItErrorResult))
//                    }
//                }
//
//                context("when authentication succeeds") {
//                    beforeEach {
//                        let authResult = TradeItAuthenticationResult()
//                        let linkCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
//                        let completionBlock = linkCalls[0].args["withCompletionBlock"] as! (TradeItResult!) -> Void
//
//                        completionBlock(authResult)
//                    }
//
//                    it("should call the onSuccess callback and return nothing") {
//                        expect(onSuccessCallbackWasCalled).to(equal(1))
//                        expect(onSecurityQuestionCallbackWasCalled).to(equal(0))
//                        expect(onFailureCallbackWasCalled).to(equal(0))
//
//                        expect(returnedTradeItResult).to(beNil())
//                    }
//
//                }
//
//                context("when a security question is asked") {
//                    let securityQuestionResult = TradeItSecurityQuestionResult()
//
//                    beforeEach {
//                        let linkCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
//                        let completionBlock = linkCalls[0].args["withCompletionBlock"] as! (TradeItResult!) -> Void
//
//                        completionBlock(securityQuestionResult)
//                    }
//
//                    it("calls the onSecurityQuestion callback and return a TradeItSecurityQuestionResult") {
//                        expect(onSuccessCallbackWasCalled).to(equal(0))
//                        expect(onSecurityQuestionCallbackWasCalled).to(equal(1))
//                        expect(onFailureCallbackWasCalled).to(equal(0))
//
//                        expect(returnedTradeItResult).to(be(securityQuestionResult))
//                    }
//                }
            }

            context("when linking fails") {
                let errorResult = TradeItErrorResult()

                beforeEach {
                    let linkCalls = tradeItConnector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")
                    let completionBlock = linkCalls[0].args["andCompletionBlock"] as! (TradeItResult!) -> Void

                    completionBlock(errorResult)
                }

                it("calls the onFailure callback with the error") {
                    expect(onSuccessCallbackWasCalled).to(equal(0))
                    expect(onFailureCallbackWasCalled).to(equal(1))

                    expect(returnedErrorResult).to(be(errorResult))
                }
            }
        }
        
        describe("getAllAccounts") {
            var returnedAccounts: [TradeItAccountPortfolio] = []

            beforeEach {
                returnedAccounts = []
                linkedBrokerManager.linkedBrokers = []
            }

            context("when there are no linked brokers") {
                it("returns an empty array") {
                    returnedAccounts = linkedBrokerManager.getAllAccounts()
                    expect(returnedAccounts.count).to(equal(0))
                }
            }

            context("when there are linked brokers") {
                let account11 = TradeItAccountPortfolio(accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                let account12 = TradeItAccountPortfolio(accountName: "My account #12", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                let account31 = TradeItAccountPortfolio(accountName: "My account #31", accountNumber: "5678901234", balance: nil, fxBalance: nil, positions: [])

                beforeEach {
                    let linkedOldLogin1 = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")
                    let linkedOldLogin2 = TradeItLinkedLogin(label: "My linked login 2", broker: "Broker #2", userId: "userId2", andKeyChainId: "keychainId2")
                    let linkedOldLogin3 = TradeItLinkedLogin(label: "My linked login 3", broker: "Broker #3", userId: "userId3", andKeyChainId: "keychainId3")

                    let tradeItSession1 = FakeTradeItSession()
                    let linkedOldBroker1 = TradeItLinkedBroker(session: tradeItSession1, linkedLogin: linkedOldLogin1)
                    linkedOldBroker1.accounts.append(account11)
                    linkedOldBroker1.accounts.append(account12)

                    let tradeItSession2 = FakeTradeItSession()
                    let linkedOldBroker2 = TradeItLinkedBroker(session: tradeItSession2, linkedLogin: linkedOldLogin2)

                    let tradeItSession3 = FakeTradeItSession()
                    let linkedOldBroker3 = TradeItLinkedBroker(session: tradeItSession3, linkedLogin: linkedOldLogin3)
                    linkedOldBroker3.accounts.append(account31)

                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker1)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker2)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker3)

                    returnedAccounts = linkedBrokerManager.getAllAccounts()
                }

                it("returns all the accounts of the linkedBrokers") {
                    expect(returnedAccounts.count).to(equal(3))
                    expect(returnedAccounts[0]).to(be(account11))
                    expect(returnedAccounts[1]).to(be(account12))
                    expect(returnedAccounts[2]).to(be(account31))
                }
            }
        }

    }
    
}