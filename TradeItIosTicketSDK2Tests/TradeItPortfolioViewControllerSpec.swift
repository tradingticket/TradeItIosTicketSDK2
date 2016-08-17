import Quick
import Nimble


class TradeItPortfolioViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItPortfolioViewController!
        var _tradeItBalanceService: FakeTradeItBalanceService!
        var tradeItConnector: FakeTradeItConnector!
        var window: UIWindow!
        var nav: UINavigationController!
        var ezLoadingActivityManager: FakeEZLoadingActivityManager!

        
        describe("initialization") {
            beforeEach {
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                
                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_PORTFOLIO_VIEW") as! TradeItPortfolioViewController
                
                let linkedRecentLogin = TradeItLinkedLogin(label: "My recent linked login", broker: "Broker recent", userId: "userIdRecent", andKeyChainId: "keychainIdRecent")
                controller.linkedLogin = linkedRecentLogin
                controller.accounts = [TradeItAccount(accountBaseCurrency: "USD", accountNumber: "123456789", accountName: "My fake account 1", tradable: true),
                                       TradeItAccount(accountBaseCurrency: "USD", accountNumber: "987654321", accountName: "My fake account 2", tradable: true),
                                       TradeItAccount(accountBaseCurrency: "USD", accountNumber: "123498765", accountName: "My fake account 3", tradable: true)
                ]

                
                tradeItConnector =  FakeTradeItConnector()
//                let linkedOldLogin1 = TradeItLinkedLogin(label: "My linked login 1", broker: "Broker #1", userId: "userId1", andKeyChainId: "keychainId1")
//                let linkedOldLogin2 = TradeItLinkedLogin(label: "My linked login 2", broker: "Broker #2", userId: "userId2", andKeyChainId: "keychainId2")
//                let linkedOldLogin3 = TradeItLinkedLogin(label: "My linked login 3", broker: "Broker #3", userId: "userId3", andKeyChainId: "keychainId3")
                
                tradeItConnector.tradeItLinkedLoginArrayToReturn = [linkedRecentLogin/**, linkedOldLogin1, linkedOldLogin2, linkedOldLogin3**/]
                
                
                ezLoadingActivityManager = FakeEZLoadingActivityManager()

                controller.tradeItSession = FakeTradeItSession()
                
                controller.tradeItConnector = tradeItConnector
                controller.ezLoadingActivityManager = ezLoadingActivityManager

                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                _tradeItBalanceService = FakeTradeItBalanceService()
                controller.tradeItBalanceService = _tradeItBalanceService
                
                NSRunLoop.currentRunLoop().runUntilDate(NSDate())
            }
            
            
            it("shows a spinner") {
                let callsToShow = ezLoadingActivityManager.calls.forMethod("show(text:disableUI:)")
                let alertText: String = callsToShow[0].args["text"] as! String
                
                expect(callsToShow.count).to(equal(1))
                expect(ezLoadingActivityManager.calls.count).to(equal(1))
                expect(alertText).to(equal("Authenticating"))
            }
            
            it("fetch the linked login") {
                expect(tradeItConnector.calls.forMethod("getLinkedLogins()").count).to(equal(1))
            }
            
            it("authenticate the previous linked login") {
                //TODO Mock tradeItSession expect()
            }
            
            it("shows a spinner") {
                let callsToShow = ezLoadingActivityManager.calls.forMethod("show(text:disableUI:)")
                let alertText: String = callsToShow[0].args["text"] as! String
                
                expect(callsToShow.count).to(equal(1))
                expect(ezLoadingActivityManager.calls.count).to(equal(1))
                //TODO does not work
                //expect(alertText).toEventually(equal("Retrieving Account Summary"))
            }

            
            it("fetch the balances for all linked login") {
                expect(_tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)").count).toEventually(equal(3))
            }
            

            context("when all calls are successfull") {
                beforeEach {
                    ezLoadingActivityManager.calls.reset()
                    
                    expect(_tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)").count).toEventually(equal(3))

                    waitUntil { done in
                        let completionBlockFirstAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                        let tradeItResult =  TradeItAccountOverviewResult()
                        tradeItResult.totalValue = 100
                        tradeItResult.buyingPower = 1000
                        completionBlockFirstAccount(tradeItResult)
                        
                        let completionBlockSecondAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[1].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                        let tradeItResult2 =  TradeItAccountOverviewResult()
                        tradeItResult2.totalValue = 200
                        tradeItResult2.buyingPower = 2000
                        completionBlockSecondAccount(tradeItResult2)
                        
                        let completionBlockThirdAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[2].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                        let tradeItResult3 =  TradeItAccountOverviewResult()
                        tradeItResult3.totalValue = 300
                        tradeItResult3.buyingPower = 3000
                        completionBlockThirdAccount(tradeItResult3)
                        
                        done()
                    }
                }
                
                it("hides the spinner") {
                    let callsToHide = ezLoadingActivityManager.calls.forMethod("hide()")
                    expect(callsToHide.count).to(equal(1)) //TODO to fix only 1 call should have been done
                    expect(ezLoadingActivityManager.calls.count).to(equal(2)) //TODO to fix only 1 call should have been done
                }
                
                it("populates the table with a list of linked brokers' accounts") {
                    let accountRowCount = controller.tableView(controller.accountsTable, numberOfRowsInSection: 0)
                    expect(accountRowCount).to(equal(controller.accounts.count))
                    
                    
                    var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("Broker recent *6789"))
                    
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("Broker recent *4321"))
                    
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("Broker recent *8765"))
                }
                
                it("populates the table with the total value and buying power for each account") {
                    
                    //Account on first row
                    var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                    
                    //let cellResult = controller.accountsTable.dequeueReusableCellWithIdentifier(controller.cellPortfolioId) as! CustomPortfolioCell
                    expect(cell.rowCellValue2?.text).to(equal("$100.00"))
                    expect(cell.rowCellValue3?.text).to(equal("$1,000.00"))
                    
                    //Account on second row
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                    
                    expect(cell.rowCellValue2?.text).to(equal("$200.00"))
                    expect(cell.rowCellValue3?.text).to(equal("$2,000.00"))
                    
                    //Account on third row
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
                    
                    expect(cell.rowCellValue2?.text).to(equal("$300.00"))
                    expect(cell.rowCellValue3?.text).to(equal("$3,000.00"))
                }
                
                it("fills the total value of all accounts under ALL ACCOUNTS") {
                    expect(controller.totalAccountsValueLabel.text).toEventually(equal("$600.00"))
                }

                
            }
            
            context("when at least one authenticate call fails") {
                //TODO
            }
            
            context("when at least one balance call fails") {
                //TODO
            }
        }
        
    }
}
