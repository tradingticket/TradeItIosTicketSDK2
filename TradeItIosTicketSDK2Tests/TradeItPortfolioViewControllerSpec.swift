import Quick
import Nimble
@testable import TradeItIosTicketSDK2

class TradeItPortfolioViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItPortfolioViewController!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var window: UIWindow!
        var nav: UINavigationController!
        var accountsTableViewManager: FakeTradeItPortfolioAccountsTableViewManager!
        var accountSummaryViewManager: FakeTradeItPortfolioAccountSummaryViewManager!
        var positionsTableViewManager: FakeTradeItPortfolioPositionsTableViewManager!
        var linkBrokerUIFlow: FakeTradeItLinkBrokerUIFlow!
        var tradingUIFlow: FakeTradeItTradingUIFlow!

        describe("initialization") {
            beforeEach {
                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                accountsTableViewManager = FakeTradeItPortfolioAccountsTableViewManager()
                positionsTableViewManager = FakeTradeItPortfolioPositionsTableViewManager()
                accountSummaryViewManager = FakeTradeItPortfolioAccountSummaryViewManager()
                linkBrokerUIFlow = FakeTradeItLinkBrokerUIFlow()
                tradingUIFlow = FakeTradeItTradingUIFlow()

                window = UIWindow()
                let bundle = Bundle(identifier: "TradeIt.TradeItIosTicketSDK2")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                TradeItSDK._linkedBrokerManager = linkedBrokerManager
                
                controller = storyboard.instantiateViewController(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNTS_VIEW") as! TradeItPortfolioAccountsViewController

//                controller.ezLoadingActivityManager = ezLoadingActivityManager // TODO: Replace with MBProgressHUD
                controller.accountsTableViewManager = accountsTableViewManager
                controller.positionsTableViewManager = positionsTableViewManager
                controller.accountSummaryViewManager = accountSummaryViewManager
                controller.linkBrokerUIFlow = linkBrokerUIFlow
                controller.tradingUIFlow = tradingUIFlow
                
                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                
                flushAsyncEvents()
            }

            it("sets up the accountsTableViewManager") {
                expect(accountsTableViewManager.accountsTable).to(be(controller.accountsTable))
            }

            it("sets up the positionsTableViewManager") {
                expect(positionsTableViewManager.positionsTable).to(be(controller.positionsTable))
            }

            xit("authenticates all the linkedBrokers") {
                let authenticateCalls = linkedBrokerManager.calls.forMethod("authenticateAll(onSecurityQuestion:onFinished:)")
                expect(authenticateCalls.count).to(equal(1))
            }

            describe("when there is a security question") {
                // TODO: ...
            }

            xdescribe("when accounts finish authenticating") {
                var accountsToReturn: [FakeTradeItLinkedBrokerAccount]!
                var account1: FakeTradeItLinkedBrokerAccount!
                var account2: FakeTradeItLinkedBrokerAccount!
                beforeEach {
                    let linkedBroker = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                    account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    account2 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, accountName: "My account #2", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])

                    accountsToReturn = [account1, account2]

                    linkedBrokerManager.hackAccountsToReturn = accountsToReturn

                    let authenticateCalls = linkedBrokerManager.calls.forMethod("authenticateAll(onSecurityQuestion:onFinished:)")
                    let callback = authenticateCalls[0].args["onFinished"] as! () -> Void

                    callback()
                    flushAsyncEvents()
                }

                it("refreshes the account balances of all the linked brokers") {
                    expect(linkedBrokerManager.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
                }

                describe("when account balances have been refreshed") {
                    beforeEach {
                        account1.balance = TradeItAccountOverview()
                        account1.balance!.totalValue = 123
                        account2.fxBalance = TradeItFxAccountOverview()
                        account2.fxBalance!.totalValueUSD = 234
                        let onFinished = linkedBrokerManager.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                        onFinished()
                        flushAsyncEvents()
                    }

                    it("populates the accounts table with the linked accounts from the linkedBrokerManager") {
                        let updateAccountsCalls = accountsTableViewManager.calls.forMethod("updateAccounts(withAccounts:withLinkedBrokersInError:)")
                        expect(updateAccountsCalls.count).to(equal(2))

                        let accountsArg = updateAccountsCalls[1].args["withAccounts"] as! [TradeItLinkedBrokerAccount]

                        expect(accountsArg).to(equal(accountsToReturn))
                    }

                    it("updates the total account value field") {
                        expect(controller.totalValueLabel.text).to(equal("$357.00"))
                    }
                }
            }

            describe("when an account is selected") {
                var account1: FakeTradeItLinkedBrokerAccount!
                var portfolioPosition: FakeTradeItPortfolioPositions!

                beforeEach {
                    let position = TradeItPosition()
                    position.costbasis = 123
                    position.holdingType = "LONG"
                    position.lastPrice = 345
                    position.quantity = 12
                    position.symbol = "My special symbol"
                    position.symbolClass = "My special symbol class"
                    position.todayGainLossDollar = 234
                    position.todayGainLossPercentage = 12
                    let linkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                    account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])

                    portfolioPosition = FakeTradeItPortfolioPositions(linkedBrokerAccount: account1, position: position)
                    account1.positions = [portfolioPosition]

                    controller.linkedBrokerAccountWasSelected(selectedAccount: account1)
                }

                it("populates the account summary") {
                    let calls = accountSummaryViewManager.calls.forMethod("populateSummarySection(selectedAccount:)")
                    expect(calls.count).to(equal(1))
                    expect(calls[0].args["selectedAccount"] as? TradeItLinkedBrokerAccount).to(equal(account1))
                }

                it("calls the getPositions method on the selected account") {
                    expect(account1.calls.forMethod("getPositions(onSuccess:onFailure:)").count).to(equal(1))
                }

                describe("when positions have been refreshed") {
                    beforeEach {
                        let onSuccess = account1.calls.forMethod("getPositions(onSuccess:onFailure:)")[0].args["onSuccess"] as! ([TradeItPortfolioPosition]) -> Void
                        onSuccess([portfolioPosition])
                    }

                    it("populates the positions table from the selectedAccount") {
                        let updatePositionsCalls = positionsTableViewManager.calls.forMethod("updatePositions(withPositions:)")
                        expect(updatePositionsCalls.count).to(equal(2))
                        
                        let positionsArg = updatePositionsCalls[1].args["withPositions"] as! [TradeItPortfolioPosition]
                        expect(positionsArg).to(equal(account1.positions))
                    }
                }
            }

            describe("when a broker in error was selected") {
                var linkedBroker: TradeItLinkedBroker!
                beforeEach {
                    linkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin(label: "My label", broker: "My broker", userId: "My userID", andKeyChainId: "My keychain"))
                    let error = TradeItErrorResult()
                    error.code = 300
                    error.shortMessage = "My short message"
                    error.longMessages = ["My long message 1", "My long message 2"]
                    linkedBroker.error = error
                    
                    controller.linkedBrokerInErrorWasSelected(selectedBrokerInError: linkedBroker)
                }
            }

            describe("when relinkAccount was tapped for a broker in error") {
                var linkedBrokerToRelink: FakeTradeItLinkedBroker!
                beforeEach {
                    linkedBrokerToRelink = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin(label: "My label", broker: "My broker", userId: "My userID", andKeyChainId: "My keychain"))
                    let error = TradeItErrorResult()
                    error.code = 300
                    error.shortMessage = "My short message"
                    error.longMessages = ["My long message 1", "My long message 2"]
                    linkedBrokerToRelink.error = error
                    linkedBrokerManager.linkedBrokers.append(linkedBrokerToRelink)
                    controller.relinkAccountWasTapped(withLinkedBroker: linkedBrokerToRelink)
                }

                it("calls the launchRelinkBrokerFlow on the linkBrokerUIFlow with the linkedBroker in error") {
                    let calls = linkBrokerUIFlow.calls.forMethod("presentRelinkBrokerFlow(inViewController:linkedBroker:onLinked:onFlowAborted:)")
                    expect(calls.count).to(equal(1))
                    let argLinkedBroker = calls[0].args["linkedBroker"] as! TradeItLinkedBroker
                    expect(argLinkedBroker).to(equal(linkedBrokerToRelink))
                }

                xdescribe("when on linked is called") {
                    var relinkAccount: TradeItLinkedBrokerAccount!
                     var fakeNavigationController: FakeUINavigationController!
                    beforeEach {
                        let calls = linkBrokerUIFlow.calls.forMethod("presentRelinkBrokerFlow(inViewController:linkedBroker:onLinked:onFlowAborted:)")
                        let onLinked = calls[0].args["onLinked"] as! (_ presentedNavController: UINavigationController) -> Void
                        linkedBrokerToRelink.error = nil
                        relinkAccount = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBrokerToRelink, accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                        linkedBrokerToRelink.accounts = [relinkAccount]
                        linkedBrokerManager.hackAccountsToReturn = [relinkAccount]
                        fakeNavigationController = FakeUINavigationController()
                        onLinked(fakeNavigationController)
                    }

                    it ("dismiss the view controller") {
                        expect(fakeNavigationController.calls.forMethod("dismissViewControllerAnimated(_:completion:)").count).to(equal(1))
                    }

                    it("calls the refreshAccountBalances on the linkedBroker") {
                        expect(linkedBrokerToRelink.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
                    }

                    describe("when refreshing balances on the linked broker is finished") {
                        beforeEach {
                            let onFinished = linkedBrokerToRelink.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                            onFinished()
                        }

                        it("populates the accounts table with the linked accounts from the linkedBrokerManager") {
                            let updateAccountsCalls = accountsTableViewManager.calls.forMethod("updateAccounts(withAccounts:withLinkedBrokersInError:)")
                            expect(updateAccountsCalls.count).to(equal(2))
                            
                            let accountsArg = updateAccountsCalls[1].args["withAccounts"] as! [TradeItLinkedBrokerAccount]
                            
                            expect(accountsArg[0]).to(equal(linkedBrokerToRelink.accounts[0]))
                        }
                    }
                }
            }

            describe("when reloadAccountWasTapped was tapped for a broker in error") {
                var linkedBrokerToReload: FakeTradeItLinkedBroker!
                beforeEach {
                    linkedBrokerToReload = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin(label: "My label", broker: "My broker", userId: "My userID", andKeyChainId: "My keychain"))
                    let error = TradeItErrorResult()
                    error.code = 300
                    error.shortMessage = "My short message"
                    error.longMessages = ["My long message 1", "My long message 2"]
                    linkedBrokerToReload.error = error
                    controller.reloadAccountWasTapped(withLinkedBroker: linkedBrokerToReload)
                }

                context("when authentication succeeds") {
                    beforeEach {
                        let relinkAccount = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBrokerToReload, accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                        linkedBrokerToReload.accounts = [relinkAccount]
                        linkedBrokerToReload.error = nil
                        linkedBrokerManager.hackAccountsToReturn = [relinkAccount]

                        let onSuccess = linkedBrokerToReload.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onSuccess"] as! (() -> Void)

                        onSuccess()
                    }

                    // TODO: Replace with MBProgressHUD
//                    itBehavesLike("refreshAccountBalances") {["linkedBroker": linkedBrokerToReload, "ezLoadingActivityManager": ezLoadingActivityManager, "accountsTableViewManager": accountsTableViewManager]}
                }

                context("when authentication fails") {
                    var errorResult: TradeItErrorResult!
                    beforeEach {
                        errorResult = TradeItErrorResult()
                        errorResult.status = "ERROR"
                        errorResult.token = "My Special Token"
                        errorResult.shortMessage = "My Special Error Title"
                        errorResult.longMessages = ["My Special Error Message"]
                        
                        linkedBrokerManager.hackLinkedBrokersInErrorToReturn = [linkedBrokerToReload]
                        let onFailure = linkedBrokerToReload.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onFailure"] as! ((TradeItErrorResult) -> Void)
                        onFailure(errorResult)
                    }

                    xit("set the error to the linked broker") {
                        expect(linkedBrokerToReload.error).to(equal(errorResult))
                    }

                    xit("populates the accounts table with the linked broker in error") {
                        let updateAccountsCalls = accountsTableViewManager.calls.forMethod("updateAccounts(withAccounts:withLinkedBrokersInError:)")
                        expect(updateAccountsCalls.count).to(equal(2))

                        let linkedBrokerInErrorArg = updateAccountsCalls[1].args["withLinkedBrokersInError"] as! [TradeItLinkedBroker]

                        expect(linkedBrokerInErrorArg[0]).to(equal(linkedBrokerToReload))
                    }
                }

                context("when security question is needed") {
                    // TODO
                }
            }
            
            describe("when tradeButton was tapped") {
                var selectedAccount: TradeItLinkedBrokerAccount!
                beforeEach {
                    selectedAccount = FakeTradeItLinkedBrokerAccount(linkedBroker: FakeTradeItLinkedBroker(), accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    
                    controller.selectedAccount = selectedAccount
                    controller.tradeButtonWasTapped(UIButton())
                }
                
                it("calls the tradingUIFlow with a selected account on the ordder param") {
                    let calls = tradingUIFlow.calls.forMethod("presentTradingFlow(fromViewController:withOrder:)")
                    expect(calls.count).to(equal(1))
                    let orderArg = calls[0].args["order"] as! TradeItOrder
                    expect(orderArg.linkedBrokerAccount).to(equal(selectedAccount))
                }

            }

            context("when at least one authenticate call fails") {
                //TODO
            }

            context("when at least one balance call fails") {
                //TODO
            }

            context("when at least one position call fails") {
                //TODO
            }
        }
    }
}

class TradeItPortfolioViewControllerSpecConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("refreshAccountBalances"){ (sharedExampleContext: @escaping SharedExampleContext) in
            var linkedBroker: FakeTradeItLinkedBroker!
            var accountsTableViewManager: FakeTradeItPortfolioAccountsTableViewManager!

            beforeEach {
                linkedBroker = sharedExampleContext()["linkedBroker"] as! FakeTradeItLinkedBroker
                accountsTableViewManager = sharedExampleContext()["accountsTableViewManager"] as! FakeTradeItPortfolioAccountsTableViewManager
            }

            it("calls the refreshAccountBalances on the linkedBroker") {
                expect(linkedBroker.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
            }

            describe("when refreshing balances on the linked broker is finished") {
                beforeEach {
                    let onFinished = linkedBroker.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                    onFinished()
                }

                it("populates the accounts table with the linked accounts from the linkedBrokerManager") {
                    let updateAccountsCalls = accountsTableViewManager.calls.forMethod("updateAccounts(withAccounts:withLinkedBrokersInError:)")
                    expect(updateAccountsCalls.count).to(equal(2))

                    let accountsArg = updateAccountsCalls[1].args["withAccounts"] as! [TradeItLinkedBrokerAccount]

                    expect(accountsArg[0]).to(equal(linkedBroker.accounts[0]))
                }
            }
        }
    }
}
