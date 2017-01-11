import Quick
import Nimble
@testable import TradeItIosTicketSDK2

class TradeItLinkedBrokerManagerSpec: QuickSpec {
    override func spec() {
        var linkedBrokerManager: TradeItLinkedBrokerManager!
        var connector: FakeTradeItConnector!
        var tradeItSession: FakeTradeItSession!
        var sessionProvider: FakeTradeItSessionProvider!

        beforeEach {
            connector = FakeTradeItConnector(apiKey: "My test api key", environment: TradeItEmsTestEnv, version: TradeItEmsApiVersion_2)
            tradeItSession = FakeTradeItSession()
            sessionProvider = FakeTradeItSessionProvider()
            sessionProvider.tradeItSessionToProvide = tradeItSession
            linkedBrokerManager = TradeItLinkedBrokerManager(connector: connector)
            linkedBrokerManager.sessionProvider = sessionProvider
        }

        describe("init") {
            context("when no linked brokers exist in the keychain") {
                it("initializes linkedBrokers to an empty array") {
                    expect(linkedBrokerManager.linkedBrokers).to(beEmpty())
                }
            }

            context("when linked brokers exist in the keychain") {
                it("initializes linkedBrokers from the linked brokers stored in the keychain") {
                    let storedLinkedLogin = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")
                    connector.tradeItLinkedLoginArrayToReturn = [storedLinkedLogin]

                    linkedBrokerManager = TradeItLinkedBrokerManager(connector: connector)

                    expect(linkedBrokerManager.linkedBrokers.count).to(equal(1))
                    expect(linkedBrokerManager.linkedBrokers[0].linkedLogin).to(equal(storedLinkedLogin))
                }
            }
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

            xit("gets the list of available brokers from the connector") {
                let getBrokersCalls = connector.calls.forMethod("getAvailableBrokersWithCompletionBlock")
                expect(getBrokersCalls.count).to(equal(1))
            }

            xcontext("when getting available brokers succeeds") {
                var brokersResult: [TradeItBroker]!

                beforeEach {
                    brokersResult = [
                        TradeItBroker.init(shortName: "My Special Short Name",
                                           longName: "My Special Long Name")
                    ]

                    let getBrokersCalls = connector.calls.forMethod("getAvailableBrokersWithCompletionBlock")
                    let completionBlock = getBrokersCalls[0].args["completionBlock"] as! ([TradeItBroker]?) -> Void

                    completionBlock(brokersResult)
                }

                it("passes the brokers to onSuccess") {
                    expect(onSuccessCallbackWasCalled).to(equal(1))
                    expect(onFailureCallbackWasCalled).to(equal(0))
                    expect(returnedBrokers).to(equal(brokersResult))
                }
            }

            xcontext("when getting available brokers fails") {
                beforeEach {
                    let getBrokersCalls = connector.calls.forMethod("getAvailableBrokersWithCompletionBlock")
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
            var onSecurityQuestionCallbackWasCalled = 0
            var onFailureCallbackWasCalled = 0

            var returnedLinkedBroker: TradeItLinkedBroker! = nil
            var returnedErrorResult: TradeItErrorResult! = nil


            beforeEach {
                onSuccessCallbackWasCalled = 0
                onSecurityQuestionCallbackWasCalled = 0
                onFailureCallbackWasCalled = 0

                let authInfo = TradeItAuthenticationInfo(id: "My Special Username",
                                                         andPassword: "My Special Password",
                                                         andBroker: "My Special Broker")

                linkedBrokerManager.linkBroker(
                    authInfo: authInfo!,
                    onSuccess: { (linkedBroker: TradeItLinkedBroker) -> Void in
                        onSuccessCallbackWasCalled += 1
                        returnedLinkedBroker = linkedBroker
                    },
                    onSecurityQuestion: { _, _, _ in
                        onSecurityQuestionCallbackWasCalled += 1
                    },
                    onFailure: { (tradeItErrorResult: TradeItErrorResult) in
                        onFailureCallbackWasCalled += 1
                        returnedErrorResult = tradeItErrorResult
                    }
                )
            }

            xit("links the broker with the connector") {
                let linkCalls = connector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")
                expect(linkCalls.count).to(equal(1))
            }

            xcontext("when linking succeeds") {
                let linkResult = TradeItAuthLinkResult()
                let linkedLogin = TradeItLinkedLogin()

                beforeEach {
                    connector.tradeItLinkedLoginToReturn = linkedLogin

                    let linkCalls = connector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")
                    let completionBlock = linkCalls[0].args["andCompletionBlock"] as! (TradeItResult!) -> Void

                    completionBlock(linkResult)
                }

                it("saves the linkedLogin to the Keychain") {
                    let saveLinkToKeychainCalls = connector.calls.forMethod("saveLinkToKeychain(_:withBroker:)")
                    expect(saveLinkToKeychainCalls.count).to(equal(1))

                    let linkResultArg = saveLinkToKeychainCalls[0].args["link"] as! TradeItAuthLinkResult
                    expect(linkResultArg).to(be(linkResult))

                    let brokerArg = saveLinkToKeychainCalls[0].args["broker"] as! String
                    expect(brokerArg).to(equal("My Special Broker"))
                }

                it("adds the linked broker to the list of linkedBrokers") {
                    expect(linkedBrokerManager.linkedBrokers.count).to(equal(1))
                    expect(linkedBrokerManager.linkedBrokers[0].linkedLogin).to(be(linkedLogin))
                }

                it("calls the onSuccess callback with the linkedBroker") {
                    expect(onSuccessCallbackWasCalled).to(equal(1))
                    expect(onFailureCallbackWasCalled).to(equal(0))

                    expect(returnedLinkedBroker.session).to(be(tradeItSession))
                    expect(returnedLinkedBroker.linkedLogin).to(be(linkedLogin))
                }
            }

            xcontext("when saving to keychain fails") {
                let linkResult = TradeItAuthLinkResult()

                beforeEach {
                    connector.tradeItLinkedLoginToReturn = nil

                    let linkCalls = connector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")
                    let completionBlock = linkCalls[0].args["andCompletionBlock"] as! (TradeItResult!) -> Void

                    completionBlock(linkResult)
                }

                it("calls the onFailure callback with an error") {
                    expect(onSuccessCallbackWasCalled).to(equal(0))
                    expect(onFailureCallbackWasCalled).to(equal(1))

                    expect(returnedErrorResult).to(beAnInstanceOf(TradeItErrorResult.self))
                }
            }

            xcontext("when linking fails") {
                let errorResult = TradeItErrorResult()

                beforeEach {
                    let linkCalls = connector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")
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
            var returnedAccounts: [TradeItLinkedBrokerAccount] = []

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
                var account11: TradeItLinkedBrokerAccount!
                var account12: TradeItLinkedBrokerAccount!
                var account31: TradeItLinkedBrokerAccount!

                beforeEach {
                    let linkedOldLogin1 = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")
                    let linkedOldLogin2 = TradeItLinkedLogin(label: "My linked login 2", broker: "Broker #2", userId: "userId2", andKeyChainId: "keychainId2")
                    let linkedOldLogin3 = TradeItLinkedLogin(label: "My linked login 3", broker: "Broker #3", userId: "userId3", andKeyChainId: "keychainId3")

                    let tradeItSession1 = FakeTradeItSession()
                    let linkedOldBroker1 = TradeItLinkedBroker(session: tradeItSession1, linkedLogin: linkedOldLogin1)
                    account11 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    linkedOldBroker1.accounts.append(account11)
                    account12 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #12", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                    linkedOldBroker1.accounts.append(account12)

                    let tradeItSession2 = FakeTradeItSession()
                    let linkedOldBroker2 = TradeItLinkedBroker(session: tradeItSession2, linkedLogin: linkedOldLogin2)
                    
                    let tradeItSession3 = FakeTradeItSession()
                    let linkedOldBroker3 = TradeItLinkedBroker(session: tradeItSession3, linkedLogin: linkedOldLogin3)
                    account31 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker3, accountName: "My account #31", accountNumber: "5678901234", balance: nil, fxBalance: nil, positions: [])
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
        
        describe("getAllEnabledAccounts") {
            var returnedAccounts: [TradeItLinkedBrokerAccount] = []
            
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
            
            context("when there are linked brokers with one disabled") {
                var account11: TradeItLinkedBrokerAccount!
                var account12: TradeItLinkedBrokerAccount!
                var account31: TradeItLinkedBrokerAccount!
                
                beforeEach {
                    let linkedOldLogin1 = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")
                    let linkedOldLogin2 = TradeItLinkedLogin(label: "My linked login 2", broker: "Broker #2", userId: "userId2", andKeyChainId: "keychainId2")
                    let linkedOldLogin3 = TradeItLinkedLogin(label: "My linked login 3", broker: "Broker #3", userId: "userId3", andKeyChainId: "keychainId3")
                    
                    let tradeItSession1 = FakeTradeItSession()
                    let linkedOldBroker1 = TradeItLinkedBroker(session: tradeItSession1, linkedLogin: linkedOldLogin1)
                    account11 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    
                    linkedOldBroker1.accounts.append(account11)
                    account12 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #12", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                    account12.isEnabled = false
                    linkedOldBroker1.accounts.append(account12)
                    
                    
                    let tradeItSession2 = FakeTradeItSession()
                    let linkedOldBroker2 = TradeItLinkedBroker(session: tradeItSession2, linkedLogin: linkedOldLogin2)
                    
                    let tradeItSession3 = FakeTradeItSession()
                    let linkedOldBroker3 = TradeItLinkedBroker(session: tradeItSession3, linkedLogin: linkedOldLogin3)
                    account31 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker3, accountName: "My account #31", accountNumber: "5678901234", balance: nil, fxBalance: nil, positions: [])
                    linkedOldBroker3.accounts.append(account31)
                    
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker1)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker2)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker3)
                    
                    
                    returnedAccounts = linkedBrokerManager.getAllEnabledAccounts()
                }
                
                it("returns all the enabled accounts of the linkedBrokers") {
                    expect(returnedAccounts.count).to(equal(2))
                    expect(returnedAccounts[0]).to(be(account11))
                    expect(returnedAccounts[1]).to(be(account31))
                }
            }
        }

        describe("getAllEnabledLinkedBrokers") {
            var returnedLinkedBrokers: [TradeItLinkedBroker] = []
            
            beforeEach {
                returnedLinkedBrokers = []
                linkedBrokerManager.linkedBrokers = []
            }
            
            context("when there are no linked brokers") {
                it("returns an empty array") {
                    returnedLinkedBrokers = linkedBrokerManager.getAllEnabledLinkedBrokers()
                    expect(returnedLinkedBrokers.count).to(equal(0))
                }
            }
            
            context("when there are linked brokers with no accounts enabled") {
                var account11: TradeItLinkedBrokerAccount!
                var account12: TradeItLinkedBrokerAccount!
                var account31: TradeItLinkedBrokerAccount!
                
                beforeEach {
                    let linkedOldLogin1 = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")
                    let linkedOldLogin2 = TradeItLinkedLogin(label: "My linked login 2", broker: "Broker #2", userId: "userId2", andKeyChainId: "keychainId2")
                    let linkedOldLogin3 = TradeItLinkedLogin(label: "My linked login 3", broker: "Broker #3", userId: "userId3", andKeyChainId: "keychainId3")
                    
                    let tradeItSession1 = FakeTradeItSession()
                    let linkedOldBroker1 = TradeItLinkedBroker(session: tradeItSession1, linkedLogin: linkedOldLogin1)
                    account11 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    account11.isEnabled = false
                    linkedOldBroker1.accounts.append(account11)
                    account12 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #12", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                    account12.isEnabled = false
                    linkedOldBroker1.accounts.append(account12)
                    
                    
                    let tradeItSession2 = FakeTradeItSession()
                    let linkedOldBroker2 = TradeItLinkedBroker(session: tradeItSession2, linkedLogin: linkedOldLogin2)
                    
                    let tradeItSession3 = FakeTradeItSession()
                    let linkedOldBroker3 = TradeItLinkedBroker(session: tradeItSession3, linkedLogin: linkedOldLogin3)
                    account31 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker3, accountName: "My account #31", accountNumber: "5678901234", balance: nil, fxBalance: nil, positions: [])
                    account31.isEnabled = false
                    linkedOldBroker3.accounts.append(account31)
                    
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker1)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker2)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker3)
                    
                    
                    returnedLinkedBrokers = linkedBrokerManager.getAllEnabledLinkedBrokers()
                }
                
                it("returns an empty array") {
                    expect(returnedLinkedBrokers.count).to(equal(0))
                }
            }
            
            context("when there are linked brokers with accounts enabled") {
                var account11: TradeItLinkedBrokerAccount!
                var account12: TradeItLinkedBrokerAccount!
                var account31: TradeItLinkedBrokerAccount!
                var linkedOldBroker1: TradeItLinkedBroker!
                beforeEach {
                    let linkedOldLogin1 = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")
                    let linkedOldLogin2 = TradeItLinkedLogin(label: "My linked login 2", broker: "Broker #2", userId: "userId2", andKeyChainId: "keychainId2")
                    let linkedOldLogin3 = TradeItLinkedLogin(label: "My linked login 3", broker: "Broker #3", userId: "userId3", andKeyChainId: "keychainId3")
                    
                    let tradeItSession1 = FakeTradeItSession()
                    linkedOldBroker1 = TradeItLinkedBroker(session: tradeItSession1, linkedLogin: linkedOldLogin1)
                    account11 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    account11.isEnabled = false
                    linkedOldBroker1.accounts.append(account11)
                    account12 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker1, accountName: "My account #12", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                    account12.isEnabled = true
                    linkedOldBroker1.accounts.append(account12)
                    
                    
                    let tradeItSession2 = FakeTradeItSession()
                    let linkedOldBroker2 = TradeItLinkedBroker(session: tradeItSession2, linkedLogin: linkedOldLogin2)
                    
                    let tradeItSession3 = FakeTradeItSession()
                    let linkedOldBroker3 = TradeItLinkedBroker(session: tradeItSession3, linkedLogin: linkedOldLogin3)
                    account31 = TradeItLinkedBrokerAccount(linkedBroker: linkedOldBroker3, accountName: "My account #31", accountNumber: "5678901234", balance: nil, fxBalance: nil, positions: [])
                    account31.isEnabled = false
                    linkedOldBroker3.accounts.append(account31)
                    
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker1)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker2)
                    linkedBrokerManager.linkedBrokers.append(linkedOldBroker3)
                    
                    
                    returnedLinkedBrokers = linkedBrokerManager.getAllEnabledLinkedBrokers()
                }
                
                it("returns an array with only the linkedBroker which has at least one account enabled") {
                    expect(returnedLinkedBrokers.count).to(equal(1))
                    expect(returnedLinkedBrokers[0]).to(be(linkedOldBroker1))
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
                    authenticatedLinkedBroker.error =  nil

                    failedUnauthenticatedLinkedBroker = FakeTradeItLinkedBroker()
                    failedUnauthenticatedLinkedBroker.error = TradeItErrorResult()

                    successfulUnauthenticatedLinkedBroker = FakeTradeItLinkedBroker()
                    successfulUnauthenticatedLinkedBroker.error = TradeItErrorResult()

                    securityQuestionUnauthenticatedLinkedBroker = FakeTradeItLinkedBroker()
                    securityQuestionUnauthenticatedLinkedBroker.error = TradeItErrorResult()

                    linkedBrokerManager.linkedBrokers = [
                        authenticatedLinkedBroker,
                        failedUnauthenticatedLinkedBroker,
                        successfulUnauthenticatedLinkedBroker,
                        securityQuestionUnauthenticatedLinkedBroker
                    ]

                    onFinishedAuthenticatingWasCalled = 0

                    linkedBrokerManager.authenticateAll(
                        onSecurityQuestion: { (result: TradeItSecurityQuestionResult, onSecurityQuestionAnswer: (String) -> Void, onCancelSecurityQuestion: () -> Void) -> Void in
                            securityQuestionCalledWith = result
                        },
                        onFinished: {
                            onFinishedAuthenticatingWasCalled += 1
                        }
                    )
                }

                it("calls authenticate only on non authenticated linkedBokers") {
                    var authenticateCalls = authenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                    expect(authenticateCalls.count).to(equal(0))

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
                    let onSecurityQuestion = authenticateCalls[0].args["onSecurityQuestion"] as! (TradeItSecurityQuestionResult, (String) -> Void, () -> Void) -> Void
                    let expectedSecurityQuestionResult = TradeItSecurityQuestionResult()

                    expect(securityQuestionCalledWith).to(beNil())

                    onSecurityQuestion(expectedSecurityQuestionResult, { _ in }, { _ in })

                    expect(securityQuestionCalledWith).to(be(expectedSecurityQuestionResult))
                }

                describe("after all brokers have finished trying to authenticate") {
                    beforeEach {
//                        var authenticateCalls = authenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
//                        var onSuccess = authenticateCalls[0].args["onSuccess"] as! () -> Void
//                        onSuccess()

                        var authenticateCalls = failedUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        let onFailure = authenticateCalls[0].args["onFailure"] as! (TradeItErrorResult) -> Void
                        onFailure(TradeItErrorResult())

                        authenticateCalls = successfulUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        var onSuccess = authenticateCalls[0].args["onSuccess"] as! () -> Void
                        onSuccess()

                        authenticateCalls = securityQuestionUnauthenticatedLinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        onSuccess = authenticateCalls[0].args["onSuccess"] as! () -> Void
                        onSuccess()

                        flushAsyncEvents()
                    }

                    it("calls onFinishedAuthenticating") {
                        // TODO: This test is very flakey. Need to figure out how to fix it. Running it by itself it is fine.
                        expect(onFinishedAuthenticatingWasCalled).to(equal(1))
                    }
                }
            }

            context("when there are no linked brokers") {
                it("calls onFinishedAuthenticating") {
                    linkedBrokerManager.linkedBrokers = []

                    var onFinishedAuthenticatingWasCalled = 0

                    linkedBrokerManager.authenticateAll(
                        onSecurityQuestion: { (result: TradeItSecurityQuestionResult, submitAnswer: (String) -> Void,  onCancelSecurityQuestion: () -> Void) -> Void in
                            
                        },
                        onFinished: {
                            onFinishedAuthenticatingWasCalled += 1
                        }
                    )

                    flushAsyncEvents()

                    expect(onFinishedAuthenticatingWasCalled).to(equal(1))
                }
            }
        }

        describe("refreshAccountBalances") {
            var onFinishedRefreshingBalancesWasCalled = 0
            var linkedBroker1: FakeTradeItLinkedBroker!
            var linkedBroker2: FakeTradeItLinkedBroker!
            var linkedBroker3: FakeTradeItLinkedBroker!
            beforeEach {
                let linkedLogin1 = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")

                let tradeItSession = FakeTradeItSession()
                linkedBroker1 = FakeTradeItLinkedBroker(session: tradeItSession, linkedLogin: linkedLogin1)
                let account11 = TradeItLinkedBrokerAccount(linkedBroker: linkedBroker1, accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                let account12 = TradeItLinkedBrokerAccount(linkedBroker: linkedBroker1, accountName: "My account #12", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                linkedBroker1.accounts = [account11, account12]
                linkedBroker1.error = nil

                let linkedLogin2 = TradeItLinkedLogin(label: "My linked login 2", broker: "Broker #2", userId: "userId2", andKeyChainId: "keychainId2")
                let tradeItSession2 = FakeTradeItSession()
                linkedBroker2 = FakeTradeItLinkedBroker(session: tradeItSession2, linkedLogin: linkedLogin2)
                let account21 = TradeItLinkedBrokerAccount(linkedBroker: linkedBroker2, accountName: "My account #21", accountNumber: "5678901234", balance: nil, fxBalance: nil, positions: [])
                linkedBroker2.accounts = [account21]
                linkedBroker2.error = nil

                let linkedLogin3 = TradeItLinkedLogin(label: "My linked login 3", broker: "Broker #3", userId: "userId3", andKeyChainId: "keychainId2")
                let tradeItSession3 = FakeTradeItSession()
                linkedBroker3 = FakeTradeItLinkedBroker(session: tradeItSession3, linkedLogin: linkedLogin3)
                let account31 = TradeItLinkedBrokerAccount(linkedBroker: linkedBroker3, accountName: "My account #31", accountNumber: "5678901234", balance: nil, fxBalance: nil, positions: [])
                linkedBroker3.accounts = [account31]
                linkedBroker3.error = TradeItErrorResult()

                linkedBrokerManager.linkedBrokers = [linkedBroker1, linkedBroker2, linkedBroker3]

                linkedBrokerManager.refreshAccountBalances(
                    onFinished: {
                        onFinishedRefreshingBalancesWasCalled += 1
                    }
                )
            }

            it("refreshes all the authenticated linkedBrokers") {
                expect(linkedBroker1.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
                expect(linkedBroker2.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
            }
// Do we still want this behavior ?
//            it("doesn't refresh the unauthenticated linkedBroker") {
//                expect(linkedBroker3.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(0))
//            }

            it("doesn't call the callback until the refresh is finished") {
                expect(onFinishedRefreshingBalancesWasCalled).to(equal(0))
            }

            describe("when all the linkedBroker are refreshed") {
                beforeEach {
                    let onFinished1 = linkedBroker1.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                    onFinished1()

                    let onFinished2 = linkedBroker2.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                    onFinished2()
                    
                    let onFinished3 = linkedBroker3.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                    onFinished3()

                    flushAsyncEvents()
                }

                it("calls onFinishedRefreshingBalancesWasCalled") {
                    expect(onFinishedRefreshingBalancesWasCalled).to(equal(1))
                }
            }
        }
    
    
        describe("relinkBroker") {
            var onSuccessCallbackWasCalled = 0
            var onSecurityQuestionWasCalled = 0
            var onFailureCallbackWasCalled = 0
            
            var returnedLinkedBroker: TradeItLinkedBroker! = nil
            var returnedErrorResult: TradeItErrorResult! = nil
            var relinkLinkedBroker: TradeItLinkedBroker!
            var relinkSession: TradeItSession!
            beforeEach {
                connector.calls.reset()
                relinkSession = FakeTradeItSession()
                relinkLinkedBroker = TradeItLinkedBroker(session: relinkSession, linkedLogin: TradeItLinkedLogin(label: "my label", broker: "My broker", userId: "My user Id", andKeyChainId: "My keychain Id "))
                linkedBrokerManager.linkedBrokers = [relinkLinkedBroker]
                onSuccessCallbackWasCalled = 0
                onSecurityQuestionWasCalled = 0
                onFailureCallbackWasCalled = 0
                
                let authInfo = TradeItAuthenticationInfo(id: "My Special Username",
                andPassword: "My Special Password",
                andBroker: "My Special Broker")!
                
                linkedBrokerManager.relinkBroker(
                    relinkLinkedBroker,
                    authInfo: authInfo,
                    onSuccess: { (linkedBroker: TradeItLinkedBroker) -> Void in
                        onSuccessCallbackWasCalled += 1
                        returnedLinkedBroker = linkedBroker
                    },
                    onSecurityQuestion: { _, _, _ in
                        onSecurityQuestionWasCalled += 1
                    },
                    onFailure: { (tradeItErrorResult: TradeItErrorResult) in
                        onFailureCallbackWasCalled += 1
                        returnedErrorResult = tradeItErrorResult
                    }
                )
            }
            
            xit("updates the user token with the connector") {
                let updateTokenCalls = connector.calls.forMethod("updateUserToken(_:withAuthenticationInfo:andCompletionBlock:)")
                expect(updateTokenCalls.count).to(equal(1))
            }
            
            xcontext("when updating succeeds") {
                let linkResult = TradeItUpdateLinkResult()
                let linkedLogin = TradeItLinkedLogin()
                
                beforeEach {
                    connector.tradeItLinkedLoginToReturn = linkedLogin
                    
                    let updateTokenCalls = connector.calls.forMethod("updateUserToken(_:withAuthenticationInfo:andCompletionBlock:)")
                    let completionBlock = updateTokenCalls[0].args["andCompletionBlock"] as! (TradeItResult?) -> Void
                    
                    completionBlock(linkResult)
                    
                }
                
                it("updates the link to the Keychain") {
                    let updateLinkToKeychainCalls = connector.calls.forMethod("updateLinkInKeychain(_:withBroker:)")
                    expect(updateLinkToKeychainCalls.count).to(equal(1))
                    
                    let linkResultArg = updateLinkToKeychainCalls[0].args["link"] as! TradeItUpdateLinkResult
                    expect(linkResultArg).to(be(linkResult))
                    
                    let brokerArg = updateLinkToKeychainCalls[0].args["broker"] as! String
                    expect(brokerArg).to(equal("My broker"))
                }
                
                it("updates the linkedlogin on the linkedBroker") {
                    expect(linkedBrokerManager.linkedBrokers.count).to(equal(1))
                    expect(linkedBrokerManager.linkedBrokers[0].linkedLogin).to(be(linkedLogin))
                }
                
                it("calls the onSuccess callback with the linkedBroker") {
                    expect(onSuccessCallbackWasCalled).to(equal(1))
                    expect(onFailureCallbackWasCalled).to(equal(0))
                
                    expect(returnedLinkedBroker.session).to(be(relinkSession))
                    expect(returnedLinkedBroker.linkedLogin).to(be(linkedLogin))
                }
            }
            
            xcontext("when updating to keychain fails") {
                let linkResult = TradeItUpdateLinkResult()
                
                beforeEach {
                    connector.tradeItLinkedLoginToReturn = nil
                    
                    let updateTokenCalls = connector.calls.forMethod("updateUserToken(_:withAuthenticationInfo:andCompletionBlock:)")
                    let completionBlock = updateTokenCalls[0].args["andCompletionBlock"] as! (TradeItResult?) -> Void
                    
                    completionBlock(linkResult)
                }
            
                it("calls the onFailure callback with an error") {
                    expect(onSuccessCallbackWasCalled).to(equal(0))
                    expect(onFailureCallbackWasCalled).to(equal(1))
                
                    expect(returnedErrorResult).to(beAnInstanceOf(TradeItErrorResult.self))
                }
            }
            
            xcontext("when updateUserToken fails") {
                let errorResult = TradeItErrorResult()
                
                beforeEach {
                    let updateTokenCalls = connector.calls.forMethod("updateUserToken(_:withAuthenticationInfo:andCompletionBlock:)")
                    let completionBlock = updateTokenCalls[0].args["andCompletionBlock"] as! (TradeItResult?) -> Void
                    
                    completionBlock(errorResult)
                }
                
                it("calls the onFailure callback with the error") {
                    expect(onSuccessCallbackWasCalled).to(equal(0))
                    expect(onFailureCallbackWasCalled).to(equal(1))
                    
                    expect(returnedErrorResult).to(be(errorResult))
                }
            }
        }
    }
}
