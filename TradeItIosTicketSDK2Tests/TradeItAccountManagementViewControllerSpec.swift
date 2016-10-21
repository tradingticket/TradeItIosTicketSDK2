import Quick
import Nimble
@testable import TradeItIosTicketSDK2

class TradeItAccountManagementViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItAccountManagementViewController!
        var accountManagementTableManager: FakeTradeItAccountManagementTableViewManager!
        var window: UIWindow!
        var nav: UINavigationController!
        var linkedBroker: FakeTradeItLinkedBroker!
        var alertManager: FakeTradeItAlertManager!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var linkBrokerUIFlow: FakeTradeItLinkBrokerUIFlow!

        describe("initialization") {
            beforeEach {
                accountManagementTableManager = FakeTradeItAccountManagementTableViewManager()
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)

                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                TradeItLauncher.linkedBrokerManager = linkedBrokerManager
                linkBrokerUIFlow = FakeTradeItLinkBrokerUIFlow(linkedBrokerManager: linkedBrokerManager)

                controller = storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.accountManagementView.rawValue) as! TradeItAccountManagementViewController

                controller.accountManagementTableManager = accountManagementTableManager
                controller.linkBrokerUIFlow = linkBrokerUIFlow
                linkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                let account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My Special Broker", accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                let account2 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My Special Broker", accountName: "My account #2", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                linkedBroker.accounts = [account1, account2]
                controller.linkedBroker = linkedBroker
                alertManager = FakeTradeItAlertManager()
                controller.alertManager = alertManager

                nav = UINavigationController(rootViewController: controller)

                window.addSubview(nav.view)

                flushAsyncEvents()
            }

            it("sets up the accountsManagementTableManager") {
                expect(accountManagementTableManager.accountsTableView).to(be(controller.accountsTableView))
            }

            it("populates the table with the linkedBrokerAccounts") {
                expect(accountManagementTableManager.calls.forMethod("updateAccounts(withAccounts:)").count).to(equal(1))
            }

            describe("pull to refresh") {
                var onRefreshCompleteWasCalled = false
                var accountsArg: [TradeItLinkedBrokerAccount]?
                beforeEach {
                    let onRefreshComplete: (withAccounts: [TradeItLinkedBrokerAccount]?)-> Void = { (withAccounts: [TradeItLinkedBrokerAccount]?) in
                        onRefreshCompleteWasCalled = true
                        accountsArg = withAccounts
                    }
                    accountManagementTableManager.calls.reset()
                    controller.refreshRequested(fromAccountManagementTableViewManager: accountManagementTableManager, onRefreshComplete: onRefreshComplete)
                    
                }
                
                it("reauthenticates the linkedBroker") {
                    expect(linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)").count).to(equal(1))
                }
                
                context("when authentication succeeds") {
                    beforeEach {
                        let onSuccess = linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onSuccess"] as! () -> Void
                        onSuccess()
                    }

                    it("calls refreshAccountBalances on the linkedBroker") {
                        expect(linkedBroker.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
                    }
                    
                    describe("when finishing to refresh balances") {
                        beforeEach {
                            let onFinished1 = linkedBroker.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                            onFinished1()
                        }

                        it("calls onRefreshComplete with the accounts") {
                            expect(onRefreshCompleteWasCalled).to(beTrue())
                            expect(accountsArg).to(equal(linkedBroker.accounts))
                        }
                    }
                }
                
                context("when authentication fails") {
                    var error: TradeItErrorResult!

                    beforeEach {
                        error = TradeItErrorResult()
                        error.longMessages = ["My long message"]
                        let onFailure = linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onFailure"] as! (TradeItErrorResult) -> Void
                        onFailure(error)
                    }

                    it("call showTradeItErrorResultAlert to display the error") {
                        let calls = alertManager.calls.forMethod("showTradeItErrorResultAlert(onViewController:errorResult:onAlertDismissed:)")
                        expect(calls.count).to(equal(1))
                        expect(calls[0].args["errorResult"] as! TradeItErrorResult).to(be(error))
                    }
                    
                    it("calls onRefreshComplete with nil") {
                        expect(onRefreshCompleteWasCalled).to(beTrue())
                        expect(accountsArg).to(beNil())
                    }
                }
                
                context("when there is a security question") {
                    //TODO
                }
            }
        
        
            describe("unlinkAccountWasTapped") {
                beforeEach {
                    controller.unlinkAccountWasTapped(controller)
                }
                
                it("calls tradeItAlert to show a modal") {
                    let calls = alertManager.calls.forMethod("showValidationAlert(onViewController:title:message:actionTitle:onValidate:onCancel:)")
                    expect(calls.count).to(equal(1))
                }
                
                describe("The user taps on unlink") {
                    context("When the user has other broker accounts") {
                        beforeEach {
                            let calls = alertManager.calls.forMethod("showValidationAlert(onViewController:title:message:actionTitle:onValidate:onCancel:)")
                            let onValidate = calls[0].args["onValidate"] as! () -> Void
                                onValidate()

                        }

                        it("calls unlink method on the linkedBrokerManager") {
                            expect(linkedBrokerManager.calls.forMethod("unlinkBroker").count).to(equal(1))
                        }
                    }
                }
                
                describe("the user taps on cancel") {
                    var accounts: [TradeItLinkedBrokerAccount]!

                    beforeEach {
                        accounts = linkedBroker.accounts
                        let calls = alertManager.calls.forMethod("showValidationAlert(onViewController:title:message:actionTitle:onValidate:onCancel:)")
                        let onCancel = calls[0].args["onCancel"] as! () -> Void
                        onCancel()
                    }
                    
                    it("stays on the account management screen with the same data") {
                        expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItAccountManagementViewController))
                        expect(accounts).to(equal(linkedBroker.accounts))
                    }
                }
            }
        
            describe("relinkAccountWasTapped") {
                beforeEach {
                    controller.relinkAccountWasTapped(controller)
                }

                it("calls the presentRelinkBrokerFlow from the linkedBrokerFlow") {
                    let calls = linkBrokerUIFlow.calls.forMethod("presentRelinkBrokerFlow(inViewController:linkedBroker:onLinked:onFlowAborted:)")
                    expect(calls.count).to(equal(1))
                }

                context("when linking is finished from the login screen") {
                   
                    var fakeNavigationController: FakeUINavigationController!
                    beforeEach {
                        let calls = linkBrokerUIFlow.calls.forMethod("presentRelinkBrokerFlow(inViewController:linkedBroker:onLinked:onFlowAborted:)")
                        let onLinked = calls[0].args["onLinked"] as! (presentedNavController: UINavigationController) -> Void
                        fakeNavigationController = FakeUINavigationController()
                       
                        onLinked(presentedNavController: fakeNavigationController)
                    }
                    
                    it ("dismiss the view controller") {
                        expect(fakeNavigationController.calls.forMethod("dismissViewControllerAnimated(_:completion:)").count).to(equal(1))
                    }
                    
                    it("calls the refreshAccountBalances on the linkedBroker") {
                        expect(linkedBroker.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
                    }
                    
                    describe("when refreshing balances is finished") {
                        var account1: TradeItLinkedBrokerAccount!
                        beforeEach {
                            account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker,brokerName: "Broker #1", accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                            linkedBroker.accounts = [account1]
                            let onFinished = linkedBroker.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                            onFinished()
                        }
                        
                        it("calls the update Account method on the accountManagementTableManager") {
                            let calls = accountManagementTableManager.calls.forMethod("updateAccounts(withAccounts:)")
                            expect(calls.count).to(equal(2))
                            let argAccounts = calls[1].args["withAccounts"] as! [TradeItLinkedBrokerAccount]
                            expect(argAccounts[0]).to(be(account1))
                        }
                    }
                }
            }
        }
    }

}
