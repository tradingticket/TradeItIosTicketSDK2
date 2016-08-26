import Quick
import Nimble
import TradeItIosEmsApi

class TradeItPortfolioViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItPortfolioViewController!
        var _tradeItBalanceService: FakeTradeItBalanceService!
        var _tradeItPositionService: FakeTradeItPositionService!
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
                
                let linkedRecentLogin = TradeItLinkedLogin(
                    label: "My recent linked login",
                    broker: "Broker recent",
                    userId: "userIdRecent",
                    andKeyChainId: "keychainIdRecent")

                controller.linkedLogin = linkedRecentLogin

                controller.accounts = [
                    TradeItBrokerAccount(
                        accountBaseCurrency: "USD",
                        accountNumber: "123456789",
                        name: "My fake account 1",
                        tradable: true),
                    TradeItBrokerAccount(
                        accountBaseCurrency: "USD",
                        accountNumber: "987654321",
                        name: "My fake account 2",
                        tradable: true),
                    TradeItBrokerAccount(accountBaseCurrency: "USD",
                        accountNumber: "123498765",
                        name: "My fake account 3",
                        tradable: true)
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
                
                _tradeItPositionService = FakeTradeItPositionService()
                controller.tradeItPositionService = _tradeItPositionService
                
                NSRunLoop.currentRunLoop().runUntilDate(NSDate())
            }
            
            
            it("shows a spinner") {
                let callsToShow = ezLoadingActivityManager.calls.forMethod("show(text:disableUI:)")
                let alertText: String = callsToShow[0].args["text"] as! String
                
                expect(callsToShow.count).to(equal(1))
                expect(ezLoadingActivityManager.calls.count).to(equal(1))
                expect(alertText).to(equal("Authenticating"))
            }
            
            it("fetches the linked logins") {
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
            

            context("when all calls are successfull") {
                beforeEach {
                    ezLoadingActivityManager.calls.reset()
                    
                    //balances calls
                    expect(_tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)").count).toEventually(equal(3))
                    
                    let completionBlockFirstAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    let tradeItResult =  TradeItAccountOverviewResult()
                    let tradeItAccountOverview = TradeItAccountOverview()
                    tradeItAccountOverview.totalValue = 100
                    tradeItAccountOverview.buyingPower = 1000
                    tradeItAccountOverview.totalPercentReturn = 5.64
                    tradeItResult.accountOverview = tradeItAccountOverview
                    completionBlockFirstAccount(tradeItResult)
                    
                    let completionBlockSecondAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[1].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    let tradeItResult2 =  TradeItAccountOverviewResult()
                    let tradeItAccountOverview2 = TradeItAccountOverview()

                    tradeItAccountOverview2.totalValue = 200
                    tradeItAccountOverview2.buyingPower = 2000
                    tradeItAccountOverview2.totalPercentReturn = 10.69
                    tradeItResult2.accountOverview = tradeItAccountOverview2
                    completionBlockSecondAccount(tradeItResult2)
                    
                    let completionBlockThirdAccount = _tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[2].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    let tradeItResult3 =  TradeItAccountOverviewResult()
                    let tradeItAccountOverviewResult3 = TradeItAccountOverview()
                    tradeItAccountOverviewResult3.totalValue = 300
                    tradeItAccountOverviewResult3.buyingPower = 3000
                    tradeItAccountOverviewResult3.totalPercentReturn = -1.68
                    tradeItResult3.accountOverview = tradeItAccountOverviewResult3
                    completionBlockThirdAccount(tradeItResult3)
                    
                    //Positions call
                    expect(_tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)").count).toEventually(equal(1))
                    
                    let completionBlockFirstAccountPositions = _tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    let tradeItResult4 =  TradeItGetPositionsResult()
                    
                    let position1 = TradeItPosition()
                    position1.symbol = "MySymbol1"
                    position1.costbasis = 200
                    position1.quantity = 2
                    position1.lastPrice = 95.48
                    position1.holdingType = "LONG"
                    let position2 = TradeItPosition()
                    position2.symbol = "MySymbol2"
                    position2.costbasis = 210.78
                    position2.quantity = 5
                    position2.lastPrice = 49.23
                    position2.holdingType = "SHORT"
                    
                    tradeItResult4.positions = [position1, position2]
                    completionBlockFirstAccountPositions(tradeItResult4)
                        
                    
                }
                
                it("hides the spinner") {
                    expect(ezLoadingActivityManager.calls.forMethod("hide()").count).toEventually(equal(1))
                    expect(ezLoadingActivityManager.calls.count).to(equal(1)) 
                }
                
                it("populates the accounts table with a list of linked brokers' accounts") {
                    let accountRowCount = controller.tableView(controller.accountsTable, numberOfRowsInSection: 0)
                    expect(accountRowCount).to(equal(controller.accounts.count))
                    
                    
                    var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("My fake ac**6789"))
                    
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("My fake ac**4321"))
                    
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("My fake ac**8765"))
                }
                
                it("populates the accounts table with the total value and buying power for each account") {
                    //Account on first row
                    var cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue2?.text).to(equal("$1,000"))
                    expect(cell.rowCellValue3?.text).to(equal("$100 (5.64%)"))
                    
                    //Account on second row
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue2?.text).to(equal("$2,000"))
                      expect(cell.rowCellValue3?.text).to(equal("$200 (10.69%)"))
                    
                    //Account on third row
                    cell = controller.tableView(controller.accountsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue2?.text).to(equal("$3,000"))
                    expect(cell.rowCellValue3?.text).to(equal("$300 (-1.68%)"))
                }
                
                it("fills the total value of all accounts under ALL ACCOUNTS") {
                    expect(controller.totalAccountsValueLabel.text).toEventually(equal("$600"))
                }
                
                it("select the first account in the accounts table") {
                    expect(controller.selectedPortfolioIndex).to(equal(0))
                }
                
                it("update the header title in the positions table") {
                    expect(controller.holdingsLabel.text).toEventually(equal("My fake ac**6789 Holdings"))
                }
                
                it("populates the positions table for the selected account") {
                    //Position on first row
                    var cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("MySymbol1"))
                    expect(cell.rowCellUnderValue1?.text).to(equal("2 shares"))
                    expect(cell.rowCellValue2?.text).to(equal("$200"))
                    expect(cell.rowCellValue3?.text).to(equal("$95.48"))
                    
                    //Position on second row
                    cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                    expect(cell.rowCellValue1?.text).to(equal("MySymbol2"))
                    expect(cell.rowCellUnderValue1?.text).to(equal("5 short"))
                    expect(cell.rowCellValue2?.text).to(equal("$210.78"))
                    expect(cell.rowCellValue3?.text).to(equal("$49.23"))
                }
                
                describe("select another account") {
                    beforeEach {
                        _tradeItPositionService.calls.reset()
                        controller.tableView(controller.accountsTable, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                        let completionBlockSecondAccountPositions = _tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                        let tradeItResult =  TradeItGetPositionsResult()
                        
                        let position1 = TradeItPosition()
                        position1.symbol = "MySymbol21"
                        position1.costbasis = 2200
                        position1.quantity = 22
                        position1.lastPrice = 295.48
                        position1.holdingType = "SHORT"
                        
                        let position2 = TradeItPosition()
                        position2.symbol = "MySymbol22"
                        position2.costbasis = 2210.78
                        position2.quantity = 25
                        position2.lastPrice = 249.23
                        position2.holdingType = "LONG"
                        
                        tradeItResult.positions = [position1, position2]
                        completionBlockSecondAccountPositions(tradeItResult)
                    }
                    it("updates the hrader title of the positions table") {
                        expect(controller.holdingsLabel.text).to(equal("My fake ac**4321 Holdings"))
                    }
                    
                    it("shows the corresponding positions") {
                        //Position on first row
                        var cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                        expect(cell.rowCellValue1?.text).to(equal("MySymbol21"))
                        expect(cell.rowCellUnderValue1?.text).to(equal("22 short"))
                        expect(cell.rowCellValue2?.text).to(equal("$2,200"))
                        expect(cell.rowCellValue3?.text).to(equal("$295.48"))
                        
                        //Position on second row
                        cell = controller.tableView(controller.holdingsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                        expect(cell.rowCellValue1?.text).to(equal("MySymbol22"))
                        expect(cell.rowCellUnderValue1?.text).to(equal("25 shares"))
                        expect(cell.rowCellValue2?.text).to(equal("$2,210.78"))
                        expect(cell.rowCellValue3?.text).to(equal("$249.23"))
                        
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
