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

        describe("authenticateAll") {
            context("when there are linked brokers") {
                var authenticatedLinkedBroker: FakeTradeItLinkedBroker!
                var failedUnauthenticatedLinkedBroker: FakeTradeItLinkedBroker!
                var successfulUnauthenticatedLinkedBroker: FakeTradeItLinkedBroker!
                var securityQuestionUnauthenticatedLinkedBroker: FakeTradeItLinkedBroker!
                var securityQuestionCalledWith: TradeItSecurityQuestionResult?
                var onFinishedAuthenticatingWasCalled = 0

                beforeEach {
                    authenticatedLinkedBroker = FakeTradeItLinkedBroker()
                    authenticatedLinkedBroker.isAuthenticated = true

                    failedUnauthenticatedLinkedBroker = FakeTradeItLinkedBroker()
                    failedUnauthenticatedLinkedBroker.isAuthenticated = false

                    successfulUnauthenticatedLinkedBroker = FakeTradeItLinkedBroker()
                    successfulUnauthenticatedLinkedBroker.isAuthenticated = false

                    securityQuestionUnauthenticatedLinkedBroker = FakeTradeItLinkedBroker()
                    securityQuestionUnauthenticatedLinkedBroker.isAuthenticated = false

                    linkedBrokerManager.linkedBrokers = [
                        authenticatedLinkedBroker,
                        failedUnauthenticatedLinkedBroker,
                        successfulUnauthenticatedLinkedBroker,
                        securityQuestionUnauthenticatedLinkedBroker
                    ]

                    onFinishedAuthenticatingWasCalled = 0

                    linkedBrokerManager.authenticateAll(
                        onSecurityQuestion: { (result: TradeItSecurityQuestionResult) -> String in
                            securityQuestionCalledWith = result
                            return ""
                        },
                        onFinishedAuthenticating: { 
                            onFinishedAuthenticatingWasCalled += 1
                        }
                    )
                }

                it("calls authenticate on each broker") {
                    var authenticateCalls = authenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                    expect(authenticateCalls.count).to(equal(1))

                    authenticateCalls = failedUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                    expect(authenticateCalls.count).to(equal(1))

                    authenticateCalls = successfulUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                    expect(authenticateCalls.count).to(equal(1))

                    authenticateCalls = securityQuestionUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                    expect(authenticateCalls.count).to(equal(1))
                }

                it("doesn't call onFinishedAuthenticating before all linked brokers have finished") {
                    expect(onFinishedAuthenticatingWasCalled).to(equal(0))
                }

                it("calls onSecurityQuestion for security questions") {
                    let authenticateCalls = securityQuestionUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                    let onSecurityQuestion = authenticateCalls[0].args["onSecurityQuestion"] as! (TradeItSecurityQuestionResult) -> String
                    let expectedSecurityQuestionResult = TradeItSecurityQuestionResult()

                    expect(securityQuestionCalledWith).to(beNil())

                    onSecurityQuestion(expectedSecurityQuestionResult)

                    expect(securityQuestionCalledWith).to(be(expectedSecurityQuestionResult))
                }

                describe("after all brokers have finished trying to authenticate") {
                    beforeEach {
                        var authenticateCalls = authenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        var onSuccess = authenticateCalls[0].args["onSuccess"] as! () -> Void
                        onSuccess()

                        authenticateCalls = failedUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        let onFailure = authenticateCalls[0].args["onFailure"] as! (TradeItErrorResult) -> Void
                        onFailure(TradeItErrorResult())

                        authenticateCalls = successfulUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        onSuccess = authenticateCalls[0].args["onSuccess"] as! () -> Void
                        onSuccess()

                        authenticateCalls = securityQuestionUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        onSuccess = authenticateCalls[0].args["onSuccess"] as! () -> Void
                        onSuccess()

                        NSRunLoop.currentRunLoop().runUntilDate(NSDate())
                    }

                    it("calls onFinishedAuthenticating") {
                        expect(onFinishedAuthenticatingWasCalled).to(equal(1))
                    }
                }
            }

            context("when there are no linked brokers") {
                it("calls onFinishedAuthenticating") {
                    linkedBrokerManager.linkedBrokers = []

                    var onFinishedAuthenticatingWasCalled = 0

                    linkedBrokerManager.authenticateAll(
                        onSecurityQuestion: { (result: TradeItSecurityQuestionResult) -> String in
                            return ""
                        },
                        onFinishedAuthenticating: {
                            onFinishedAuthenticatingWasCalled += 1
                        }
                    )

                    NSRunLoop.currentRunLoop().runUntilDate(NSDate())

                    expect(onFinishedAuthenticatingWasCalled).to(equal(1))
                }
            }
        }
    }
}