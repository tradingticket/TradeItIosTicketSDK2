import Quick
import Nimble


class TradeItPortfolioViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItPortfolioViewController!
        var tradeItBalanceService: FakeTradeItBalanceService!
        var window: UIWindow!
        var nav: UINavigationController!
        
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
                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                tradeItBalanceService = FakeTradeItBalanceService()
                controller.tradeItBalanceService = tradeItBalanceService
                
                NSRunLoop.currentRunLoop().runUntilDate(NSDate())
            }
            
            it("populates the table with a list of linked brokers' accounts") {
                let accountRowCount = controller.tableView(controller.accountsTable, numberOfRowsInSection: 0)
                expect(accountRowCount).to(equal(controller.accounts.count))
                
                
                var cell = controller.tableView(controller.accountsTable,
                                                cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! CustomPortfolioCell
                expect(cell.rowCellValue1?.text).to(equal("B5 *6789"))
                
                cell = controller.tableView(controller.accountsTable,
                                            cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! CustomPortfolioCell
                expect(cell.rowCellValue2?.text).to(equal("B5 *4321"))
                
                cell = controller.tableView(controller.accountsTable,
                                            cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! CustomPortfolioCell
                expect(cell.rowCellValue3?.text).to(equal("B5 *8765"))
            }
            
            it("retrieves Buying Power and Total Value for accounts") {
                expect(tradeItBalanceService.calls.forMethod("getAccountOverview").count).to(equal(controller.accounts.count))
            }

        }
        
    }
}
