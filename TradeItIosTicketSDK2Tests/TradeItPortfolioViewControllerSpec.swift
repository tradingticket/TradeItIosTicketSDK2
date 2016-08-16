import Quick
import Nimble


class TradeItPortfolioViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItPortfolioViewController!
        var tradeItBalanceService: FakeTradeItBalanceService!
        var window: UIWindow!
        var nav: UINavigationController!
        var ezLoadingActivityManager: FakeEZLoadingActivityManager!

        
        describe("initialization") {
            beforeEach {
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                
                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_PORTFOLIO_VIEW") as! TradeItPortfolioViewController
                
                
                controller.accounts = [TradeItAccount(accountBaseCurrency: "USD", accountNumber: "123456789", accountName: "My fake account 1", tradable: true),
                                       TradeItAccount(accountBaseCurrency: "USD", accountNumber: "987654321", accountName: "My fake account 2", tradable: true),
                                       TradeItAccount(accountBaseCurrency: "USD", accountNumber: "123498765", accountName: "My fake account 3", tradable: true)
                ]
                controller.selectedBroker = TradeItBroker(shortName: "B5", longName: "Broker #5")
                tradeItBalanceService = FakeTradeItBalanceService()
                controller.tradeItBalanceService = tradeItBalanceService
                ezLoadingActivityManager = FakeEZLoadingActivityManager()
                controller.ezLoadingActivityManager = ezLoadingActivityManager

                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                
                
                NSRunLoop.currentRunLoop().runUntilDate(NSDate())
            }
            
            it("populates the table with a list of linked brokers' accounts") {
                let accountRowCount = controller.tableView(controller.accountsTable, numberOfRowsInSection: 0)
                expect(accountRowCount).to(equal(controller.accounts.count))
                
                
                var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                expect(cell.rowCellValue1?.text).to(equal("B5 *6789"))
                
                cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                expect(cell.rowCellValue1?.text).to(equal("B5 *4321"))
                
                cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
                expect(cell.rowCellValue1?.text).to(equal("B5 *8765"))
            }
            
        
            it("shows a spinner") {
                let callsToShow = ezLoadingActivityManager.calls.forMethod("show(text:disableUI:)")
                let alertText: String = callsToShow[0].args["text"] as! String
                
                expect(callsToShow.count).to(equal(3)) //TODO to fix only 1 call should have been done
                expect(ezLoadingActivityManager.calls.count).to(equal(3)) //TODO to fix only 1 call should have been done
                expect(alertText).to(equal("Retreiving Account Summary"))
            }
            
            it("fetch the accountoverview") {
                expect(tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)").count).to(equal(controller.accounts.count))
            }
            
            context("when the call is successfull") {
                beforeEach {
                    ezLoadingActivityManager.calls.reset()
                    let completionBlockFirstAccount = tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    let tradeItResult =  TradeItAccountOverviewResult()
                    tradeItResult.totalValue = 100
                    tradeItResult.buyingPower = 1000
                    completionBlockFirstAccount(tradeItResult)
                    
                    let completionBlockSecondAccount = tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[1].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    let tradeItResult2 =  TradeItAccountOverviewResult()
                    tradeItResult2.totalValue = 200
                    tradeItResult2.buyingPower = 2000
                    completionBlockSecondAccount(tradeItResult2)
                    
                    let completionBlockThirdAccount = tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[2].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    let tradeItResult3 =  TradeItAccountOverviewResult()
                    tradeItResult3.totalValue = 300
                    tradeItResult3.buyingPower = 3000
                    completionBlockThirdAccount(tradeItResult3)
                }
                
                it("hides the spinner") {
                    let callsToHide = ezLoadingActivityManager.calls.forMethod("hide()")
                    expect(callsToHide.count).to(equal(3)) //TODO to fix only 1 call should have been done
                    expect(ezLoadingActivityManager.calls.count).to(equal(3)) //TODO to fix only 1 call should have been done
                }
                
                it("populates the table with the total value and buying power for each account") {
                    
                    //Account on first row
                    var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                   
                    controller.accountsTable.reloadData()
                    let cellResult = controller.accountsTable.dequeueReusableCellWithIdentifier(controller.cellPortfolioId) as! CustomPortfolioCell
                    expect(cellResult.rowCellValue2?.text).to(equal("$100"))
                    expect(cellResult.rowCellValue3?.text).to(equal("$1000"))
                    
                    //Account on second row
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                    
                    expect(cell.rowCellValue2?.text).to(equal("$200"))
                    expect(cell.rowCellValue3?.text).to(equal("$2000"))
                    
                    //Account on third row
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
                    
                    expect(cell.rowCellValue2?.text).to(equal("$300"))
                    expect(cell.rowCellValue3?.text).to(equal("$3000"))
                }

            }
            
        }
        
    }
}
