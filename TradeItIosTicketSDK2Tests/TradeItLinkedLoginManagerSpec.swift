import Quick
import Nimble
@testable import TradeItIosEmsApi

class TradeItLinkedLoginManagerSpec: QuickSpec {
    override func spec() {
        var linkedLoginManager: TradeItLinkedLoginManager!
        var tradeItConnector: FakeTradeItConnector!
        var tradeItSession: FakeTradeItSession!
        var tradeItSessionProvider: FakeTradeItSessionProvider!

        describe("linking a broker") {
            var onSuccessCallbackWasCalled = 0
            var onSecurityQuestionCallbackWasCalled = 0
            var onFailureCallbackWasCalled = 0
            var returnedTradeItResult: TradeItResult! = nil

            beforeEach {
                onSuccessCallbackWasCalled = 0
                onSecurityQuestionCallbackWasCalled = 0
                onFailureCallbackWasCalled = 0

                tradeItConnector = FakeTradeItConnector()
                tradeItSession = FakeTradeItSession()
                tradeItSessionProvider = FakeTradeItSessionProvider()
                tradeItSessionProvider.tradeItSessionToProvide = tradeItSession

                linkedLoginManager = TradeItLinkedLoginManager(connector: tradeItConnector)
                linkedLoginManager.tradeItSessionProvider = tradeItSessionProvider

                let authInfo = TradeItAuthenticationInfo(id: "My Special Username",
                                                         andPassword: "My Special Password",
                                                         andBroker: "My Special Broker")

                linkedLoginManager.linkBroker(
                    authInfo: authInfo,
                    onSuccess: {
                        onSuccessCallbackWasCalled += 1
                        returnedTradeItResult = nil
                    },
                    onSecurityQuestion: { (tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String in
                        onSecurityQuestionCallbackWasCalled += 1
                        returnedTradeItResult = tradeItSecurityQuestionResult
                        return "My Special Security Answer"
                    },
                    onFailure: { (tradeItErrorResult: TradeItErrorResult) in
                        onFailureCallbackWasCalled += 1
                        returnedTradeItResult = tradeItErrorResult
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

                it("should authenticate with the session") {
                    let authenticateCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")

                    expect(tradeItSession.calls.count).to(equal(1))
                    expect(authenticateCalls.count).to(equal(1))
                    expect(authenticateCalls[0].args["linkedLogin"] as! TradeItLinkedLogin).to(be(linkedLogin))
                }

                context("when authentication fails") {
                    beforeEach {
                        let tradeItErrorResult = TradeItErrorResult()
                        let linkCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
                        let completionBlock = linkCalls[0].args["withCompletionBlock"] as! (TradeItResult!) -> Void

                        completionBlock(tradeItErrorResult)
                    }

                    it("should call the onFailure callback and return a TradeItErrorResult") {
                        expect(onSuccessCallbackWasCalled).to(equal(0))
                        expect(onSecurityQuestionCallbackWasCalled).to(equal(0))
                        expect(onFailureCallbackWasCalled).to(equal(1))

                        expect(returnedTradeItResult).to(beAnInstanceOf(TradeItErrorResult))
                    }
                }

                context("when authentication succeeds") {
                    beforeEach {
                        let authResult = TradeItAuthenticationResult()
                        let linkCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
                        let completionBlock = linkCalls[0].args["withCompletionBlock"] as! (TradeItResult!) -> Void

                        completionBlock(authResult)
                    }

                    it("should call the onSuccess callback and return nothing") {
                        expect(onSuccessCallbackWasCalled).to(equal(1))
                        expect(onSecurityQuestionCallbackWasCalled).to(equal(0))
                        expect(onFailureCallbackWasCalled).to(equal(0))

                        expect(returnedTradeItResult).to(beNil())
                    }

                }

                context("when a security question is asked") {
                    let securityQuestionResult = TradeItSecurityQuestionResult()

                    beforeEach {
                        let linkCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
                        let completionBlock = linkCalls[0].args["withCompletionBlock"] as! (TradeItResult!) -> Void

                        completionBlock(securityQuestionResult)
                    }

                    it("calls the onSecurityQuestion callback and return a TradeItSecurityQuestionResult") {
                        expect(onSuccessCallbackWasCalled).to(equal(0))
                        expect(onSecurityQuestionCallbackWasCalled).to(equal(1))
                        expect(onFailureCallbackWasCalled).to(equal(0))

                        expect(returnedTradeItResult).to(be(securityQuestionResult))
                    }
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
                    expect(onSecurityQuestionCallbackWasCalled).to(equal(0))
                    expect(onFailureCallbackWasCalled).to(equal(1))

                    expect(returnedTradeItResult).to(be(errorResult))
                }
            }
        }
    }
}