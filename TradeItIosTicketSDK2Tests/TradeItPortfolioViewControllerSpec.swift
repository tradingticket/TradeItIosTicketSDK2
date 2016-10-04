import Quick
import Nimble
import TradeItIosEmsApi

class TradeItPortfolioViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItPortfolioViewController!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var window: UIWindow!
        var nav: UINavigationController!
        var ezLoadingActivityManager: FakeEZLoadingActivityManager!
        var accountsTableViewManager: FakeTradeItPortfolioAccountsTableViewManager!
        var positionsTableViewManager: FakeTradeItPortfolioPositionsTableViewManager!

        describe("initialization") {
            beforeEach {
                ezLoadingActivityManager = FakeEZLoadingActivityManager()
                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                accountsTableViewManager = FakeTradeItPortfolioAccountsTableViewManager()
                positionsTableViewManager = FakeTradeItPortfolioPositionsTableViewManager()
                
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                TradeItLauncher.linkedBrokerManager = linkedBrokerManager
                
                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_PORTFOLIO_VIEW") as! TradeItPortfolioViewController

                controller.ezLoadingActivityManager = ezLoadingActivityManager
                controller.accountsTableViewManager = accountsTableViewManager
                controller.positionsTableViewManager = positionsTableViewManager
                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                
                flushAsyncEvents()
            }

            it("sets up the accountsTableViewManager") {
                expect(accountsTableViewManager.accountsTable).to(be(controller.accountsTable))
            }

            it("shows a spinner") {
                expect(ezLoadingActivityManager.spinnerIsShowing).to(beTrue())
                expect(ezLoadingActivityManager.spinnerText).to(equal("Authenticating"))
            }

            it("authenticates all the linkedBrokers") {
                let authenticateCalls = linkedBrokerManager.calls.forMethod("authenticateAll(onSecurityQuestion:onFinished:)")
                expect(authenticateCalls.count).to(equal(1))
            }

            describe("when there is a security question") {
                // TODO: ...
            }

            describe("when accounts finish authenticating") {
                var accountsToReturn: [FakeTradeItLinkedBrokerAccount]!
                var account1: FakeTradeItLinkedBrokerAccount!
                var account2: FakeTradeItLinkedBrokerAccount!
                beforeEach {
                    let linkedBroker = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                    account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My Special Broker", accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    account2 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My Special Broker", accountName: "My account #2", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])

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

                it("changes the spinner text") {
                    expect(ezLoadingActivityManager.spinnerIsShowing).to(beTrue())
                    expect(ezLoadingActivityManager.spinnerText).to(equal("Refreshing Accounts"))
                }


                describe("when account balances have been refreshed") {
                    beforeEach {
                        account1.balance = TradeItAccountOverview()
                        account1.balance.totalValue = 123
                        account2.fxBalance = TradeItFxAccountOverview()
                        account2.fxBalance.totalValueUSD = 234
                        let onFinished = linkedBrokerManager.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                        onFinished()
                        flushAsyncEvents()
                    }

                    it("hides the spinner") {
                        expect(ezLoadingActivityManager.spinnerIsShowing).to(beFalse())
                    }

                    it("populates the accounts table with the linked accounts from the linkedBrokerManager") {
                        let updateAccountsCalls = accountsTableViewManager.calls.forMethod("updateAccounts(withAccounts:)")
                        expect(updateAccountsCalls.count).to(equal(2))

                        let accountsArg = updateAccountsCalls[1].args["withAccounts"] as! [TradeItLinkedBrokerAccount]

                        expect(accountsArg).to(equal(accountsToReturn))
                    }
                    
                    it("updates the total account value field") {
                        expect(controller.totalValueLabel.text).to(equal("$357"))
                    }
                }
            }
            
            describe("when an account is selected") {
                var account1: FakeTradeItLinkedBrokerAccount!
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
                    account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My Special Broker", accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                    
                    let portfolioPosition = FakeTradeItPortfolioPositions(linkedBrokerAccount: account1, position: position)
                    account1.positions = [portfolioPosition]
                    
            
                    controller.linkedBrokerAccountWasSelected(selectedAccount: account1)
                }
                
                it("shows a spinner") {
                    expect(controller.holdingsActivityIndicator.isAnimating()).to(beTrue())
                }
                
                it("calls the getPositions method on the selected account") {
                    expect(account1.calls.forMethod("getPositions(onFinished:)").count).to(equal(1))
                }
                
                describe("when positions have been refreshed") {
                    beforeEach {
                        let onFinished = account1.calls.forMethod("getPositions(onFinished:)")[0].args["onFinished"] as! () -> Void
                        onFinished()
                    }
                    it("hides the spinner") {
                        expect(controller.holdingsActivityIndicator.isAnimating()).to(beFalse())
                    }
                    
                    it("populates the positions table from the selectedAccount") {
                        let updatePositionsCalls = positionsTableViewManager.calls.forMethod("updatePositions(withPositions:)")
                        expect(updatePositionsCalls.count).to(equal(2))
                        
                        let positionsArg = updatePositionsCalls[1].args["withPositions"] as! [TradeItPortfolioPosition]
                        expect(positionsArg).to(equal(account1.positions))
                    }
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
