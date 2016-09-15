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
                    }

                    it("hides the spinner") {
                        expect(ezLoadingActivityManager.spinnerIsShowing).to(beFalse())
                    }

                    it("populates the accounts table with the linked accounts from the linkedBrokerManager") {
                        let updateAccountsCalls = accountsTableViewManager.calls.forMethod("updateAccounts(withAccounts:)")
                        expect(updateAccountsCalls.count).to(equal(1))

                        let accountsArg = updateAccountsCalls[0].args["withAccounts"] as! [TradeItLinkedBrokerAccount]

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
                        expect(updatePositionsCalls.count).to(equal(1))
                        
                        let positionsArg = updatePositionsCalls[0].args["withPositions"] as! [TradeItPortfolioPosition]
                        expect(positionsArg).to(equal(account1.positions))
                    }
                }
            }


            

//            it("shows a spinner") {
//                let callsToShow = ezLoadingActivityManager.calls.forMethod("show(text:disableUI:)")
//                let alertText: String = callsToShow[0].args["text"] as! String
//                
//                expect(callsToShow.count).to(equal(1))
//                expect(ezLoadingActivityManager.calls.count).to(equal(1))
//                expect(alertText).to(equal("Authenticating"))
//            }
//            
//            it("fetches the linked logins") {
//                expect(tradeItConnector.calls.forMethod("getLinkedLogins()").count).to(equal(1))
//            }
//            
//            it("authenticate the previous linked login") {
//                //TODO Mock tradeItSession expect()
//            }
//            
//            it("shows a spinner") {
//                let callsToShow = ezLoadingActivityManager.calls.forMethod("show(text:disableUI:)")
//                let alertText: String = callsToShow[0].args["text"] as! String
//                
//                expect(callsToShow.count).to(equal(1))
//                expect(ezLoadingActivityManager.calls.count).to(equal(1))
//                //TODO does not work
//                //expect(alertText).toEventually(equal("Retrieving Account Summary"))
//            }
//            
//
//            context("when all calls are successfull") {
//                beforeEach {
//                    ezLoadingActivityManager.calls.reset()
//                    
//                    //balances calls
//                    expect(_tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)").count).toEventually(equal(3))
//                    
//                    let completionBlockFirstAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
//                    let tradeItResult =  TradeItAccountOverviewResult()
//                    let tradeItAccountOverview = TradeItAccountOverview()
//                    tradeItAccountOverview.totalValue = 100
//                    tradeItAccountOverview.buyingPower = 1000
//                    tradeItAccountOverview.totalPercentReturn = 5.64
//                    tradeItResult.accountOverview = tradeItAccountOverview
//                    completionBlockFirstAccount(tradeItResult)
//                    
//                    let completionBlockSecondAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[1].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
//                    let tradeItResult2 =  TradeItAccountOverviewResult()
//                    let tradeItAccountOverview2 = TradeItAccountOverview()
//
//                    tradeItAccountOverview2.totalValue = 200
//                    tradeItAccountOverview2.buyingPower = 2000
//                    tradeItAccountOverview2.totalPercentReturn = 10.69
//                    tradeItResult2.accountOverview = tradeItAccountOverview2
//                    completionBlockSecondAccount(tradeItResult2)
//                    
//                    let completionBlockThirdAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[2].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
//                    let tradeItResult3 =  TradeItAccountOverviewResult()
//                    let tradeItAccountOverviewResult3 = TradeItAccountOverview()
//                    tradeItAccountOverviewResult3.totalValue = 300
//                    tradeItAccountOverviewResult3.buyingPower = 3000
//                    tradeItAccountOverviewResult3.totalPercentReturn = -1.68
//                    tradeItResult3.accountOverview = tradeItAccountOverviewResult3
//                    completionBlockThirdAccount(tradeItResult3)
//                    
//                    //Positions call
//                    expect(_tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)").count).toEventually(equal(1))
//                    
//                    let completionBlockFirstAccountPositions = _tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
//                    let tradeItResult4 =  TradeItGetPositionsResult()
//                    
//                    let position1 = TradeItPosition()
//                    position1.symbol = "MySymbol1"
//                    position1.costbasis = 200
//                    position1.quantity = 2
//                    position1.lastPrice = 95.48
//                    position1.holdingType = "LONG"
//                    let position2 = TradeItPosition()
//                    position2.symbol = "MySymbol2"
//                    position2.costbasis = 210.78
//                    position2.quantity = 5
//                    position2.lastPrice = 49.23
//                    position2.holdingType = "SHORT"
//                    
//                    tradeItResult4.positions = [position1, position2]
//                    completionBlockFirstAccountPositions(tradeItResult4)
//                        
//                    
//                }
//                
//                it("hides the spinner") {
//                    expect(ezLoadingActivityManager.calls.forMethod("hide()").count).toEventually(equal(1))
//                    expect(ezLoadingActivityManager.calls.count).to(equal(1)) 
//                }
//                
//                it("populates the accounts table with a list of linked brokers' accounts") {
//                    let accountRowCount = controller.tableView(controller.accountsTable, numberOfRowsInSection: 0)
//                    expect(accountRowCount).to(equal(controller.accounts.count))
//                    
//                    
//                    var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue1?.text).to(equal("My fake ac**6789"))
//                    
//                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue1?.text).to(equal("My fake ac**4321"))
//                    
//                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue1?.text).to(equal("My fake ac**8765"))
//                }
//                
//                it("populates the accounts table with the total value and buying power for each account") {
//                    //Account on first row
//                    var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue2?.text).to(equal("$1,000"))
//                    expect(cell.rowCellValue3?.text).to(equal("$100 (5.64%)"))
//                    
//                    //Account on second row
//                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue2?.text).to(equal("$2,000"))
//                      expect(cell.rowCellValue3?.text).to(equal("$200 (10.69%)"))
//                    
//                    //Account on third row
//                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue2?.text).to(equal("$3,000"))
//                    expect(cell.rowCellValue3?.text).to(equal("$300 (-1.68%)"))
//                }
//                
//                it("fills the total value of all accounts under ALL ACCOUNTS") {
//                    expect(controller.totalAccountsValueLabel.text).toEventually(equal("$600"))
//                }
//                
//                it("select the first account in the accounts table") {
//                    expect(controller.selectedPortfolioIndex).to(equal(0))
//                }
//                
//                it("update the header title in the positions table") {
//                    expect(controller.holdingsLabel.text).toEventually(equal("My fake ac**6789 Holdings"))
//                }
//                
//                it("populates the positions table for the selected account") {
//                    //Position on first row
//                    var cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue1?.text).to(equal("MySymbol1"))
//                    expect(cell.rowCellUnderValue1?.text).to(equal("2 shares"))
//                    expect(cell.rowCellValue2?.text).to(equal("$200"))
//                    expect(cell.rowCellValue3?.text).to(equal("$95.48"))
//                    
//                    //Position on second row
//                    cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
//                    expect(cell.rowCellValue1?.text).to(equal("MySymbol2"))
//                    expect(cell.rowCellUnderValue1?.text).to(equal("5 short"))
//                    expect(cell.rowCellValue2?.text).to(equal("$210.78"))
//                    expect(cell.rowCellValue3?.text).to(equal("$49.23"))
//                }
//                
//                describe("select another account") {
//                    beforeEach {
//                        _tradeItPositionService.calls.reset()
//                        controller.tableView(controller.accountsTable, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
//                        let completionBlockSecondAccountPositions = _tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
//                        let tradeItResult =  TradeItGetPositionsResult()
//                        
//                        let position1 = TradeItPosition()
//                        position1.symbol = "MySymbol21"
//                        position1.costbasis = 2200
//                        position1.quantity = 22
//                        position1.lastPrice = 295.48
//                        position1.holdingType = "SHORT"
//                        
//                        let position2 = TradeItPosition()
//                        position2.symbol = "MySymbol22"
//                        position2.costbasis = 2210.78
//                        position2.quantity = 25
//                        position2.lastPrice = 249.23
//                        position2.holdingType = "LONG"
//                        
//                        tradeItResult.positions = [position1, position2]
//                        completionBlockSecondAccountPositions(tradeItResult)
//                    }
//                    it("updates the hrader title of the positions table") {
//                        expect(controller.holdingsLabel.text).to(equal("My fake ac**4321 Holdings"))
//                    }
//                    
//                    it("shows the corresponding positions") {
//                        //Position on first row
//                        var cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
//                        expect(cell.rowCellValue1?.text).to(equal("MySymbol21"))
//                        expect(cell.rowCellUnderValue1?.text).to(equal("22 short"))
//                        expect(cell.rowCellValue2?.text).to(equal("$2,200"))
//                        expect(cell.rowCellValue3?.text).to(equal("$295.48"))
//                        
//                        //Position on second row
//                        cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
//                        expect(cell.rowCellValue1?.text).to(equal("MySymbol22"))
//                        expect(cell.rowCellUnderValue1?.text).to(equal("25 shares"))
//                        expect(cell.rowCellValue2?.text).to(equal("$2,210.78"))
//                        expect(cell.rowCellValue3?.text).to(equal("$249.23"))
//                        
//                    }
//                }
//                
//            }

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
