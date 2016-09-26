import Quick
import Nimble
import TradeItIosEmsApi

class TradeItAccountManagementViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItAccountManagementViewController!
        var accountsManagementTableManager: FakeTradeItAccountManagementTableViewManager!
        var window: UIWindow!
        var nav: UINavigationController!
        var selectedBroker: FakeTradeItLinkedBroker!
        var tradeItAlert: FakeTradeItAlert!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var linkBrokerUIFlow: FakeTradeItLinkBrokerUIFlow!
        
        describe("initialization") {
            beforeEach {
                accountsManagementTableManager = FakeTradeItAccountManagementTableViewManager()
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                TradeItLauncher.linkedBrokerManager = linkedBrokerManager
                linkBrokerUIFlow = FakeTradeItLinkBrokerUIFlow(linkedBrokerManager: linkedBrokerManager)

                controller = storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.accountManagementView.rawValue) as! TradeItAccountManagementViewController

                controller.accountsManagementTableManager = accountsManagementTableManager
                controller.linkBrokerUIFlow = linkBrokerUIFlow
                selectedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                let account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: selectedBroker, brokerName: "My Special Broker", accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                let account2 = FakeTradeItLinkedBrokerAccount(linkedBroker: selectedBroker, brokerName: "My Special Broker", accountName: "My account #2", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                selectedBroker.accounts = [account1, account2]
                controller.selectedLinkedBroker = selectedBroker
                tradeItAlert = FakeTradeItAlert()
                controller.tradeItAlert = tradeItAlert
                
                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                
                flushAsyncEvents()
            }
            
            it("sets up the accountsManagementTableManager") {
                expect(accountsManagementTableManager.accountsTable).to(be(controller.accountsTableView))
            }
            
            it("populates the table with the linkedBrokerAccounts") {
                expect(accountsManagementTableManager.calls.forMethod("updateAccounts(withAccounts:)").count).to(equal(1))
            }
            
            describe("pull to refresh") {
                beforeEach {
                    accountsManagementTableManager.calls.reset()
                    controller.refreshAccountsTable(self)
                }
                
                it("reauthenticates the linkedBroker") {
                    expect(selectedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)").count).to(equal(1))
                }
                
                context("when authentication succeeds") {
                    beforeEach {
                        let onSuccess = selectedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onSuccess"] as! () -> Void
                        onSuccess()
                    }
                    it("calls refreshAccountBalances on the linkedBroker") {
                        expect(selectedBroker.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
                    }
                    
                    describe("when finishing to refresh balances") {
                        beforeEach {
                            let onFinished1 = selectedBroker.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                            onFinished1()
                        }
                        it("update the table with the fresh infos") {
                            let calls = accountsManagementTableManager.calls.forMethod("updateAccounts(withAccounts:)")
                            expect(calls.count).to(equal(1))
                            let accountsArg = calls[0].args["withAccounts"] as! [TradeItLinkedBrokerAccount]
                            expect(accountsArg).to(equal(selectedBroker.accounts))
                        }
                    }
                }
                
                context("when authentication fails") {
                    var error: TradeItErrorResult!
                    beforeEach {
                        error = TradeItErrorResult()
                        error.longMessages = ["My long message"]
                        let onFailure = selectedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onFailure"] as! (TradeItErrorResult) -> Void
                        onFailure(error)
                    }
                    it("call showTradeItErrorResultAlert to display the error") {
                        let calls = tradeItAlert.calls.forMethod("showTradeItErrorResultAlert(onController:withError:withCompletion:)")
                        expect(calls.count).to(equal(1))
                        expect(calls[0].args["withError"] as! TradeItErrorResult).to(be(error))
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
                    let calls = tradeItAlert.calls.forMethod("showValidationAlert(onController:withTitle:withMessage:withActionOkTitle:onValidate:onCancel:withCompletion:)")
                    expect(calls.count).to(equal(1))
                }
                
                describe("The user taps on unlink") {
            
                    context("When the user has other broker accounts") {
                        beforeEach {
                            let calls = tradeItAlert.calls.forMethod("showValidationAlert(onController:withTitle:withMessage:withActionOkTitle:onValidate:onCancel:withCompletion:)")
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
                        accounts = selectedBroker.accounts
                        let calls = tradeItAlert.calls.forMethod("showValidationAlert(onController:withTitle:withMessage:withActionOkTitle:onValidate:onCancel:withCompletion:)")
                        let onCancel = calls[0].args["onCancel"] as! () -> Void
                        onCancel()
                    }
                    
                    it("stays on the account management screen with the same data") {
                        expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItAccountManagementViewController))
                        expect(accounts).to(equal(selectedBroker.accounts))
                    }
                }
            }
        
            describe("relinkAccountWasTapped") {
                beforeEach {
                    controller.relinkAccountWasTapped(controller)
                }
                it("calls the launchIntoLoginScreen from the linkedBrokerFlow") {
                    let calls = linkBrokerUIFlow.calls.forMethod("launchIntoLoginScreen(inViewController:selectedBroker:selectedReLinkedBroker:mode:onLinked:onFlowAborted:)")
                    expect(calls.count).to(equal(1))
                }
                context("when linking is finished from the login screen") {
                    var fakeNavigationController: FakeUINavigationController!
                    beforeEach {
                        let calls = linkBrokerUIFlow.calls.forMethod("launchIntoLoginScreen(inViewController:selectedBroker:selectedReLinkedBroker:mode:onLinked:onFlowAborted:)")
                        let onLinked = calls[0].args["onLinked"] as! (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void
                        fakeNavigationController = FakeUINavigationController()
                        let linkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                        let account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker,brokerName: "Broker #1", accountName: "My account #11", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])

                            
                        onLinked(presentedNavController: fakeNavigationController, selectedAccount: account1)
                    }
                    it("refreshes the account balance of the account") {
                        
                    }
                }
            }
        }
    }

}
