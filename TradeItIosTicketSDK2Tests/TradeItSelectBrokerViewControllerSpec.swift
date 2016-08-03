import Quick
import Nimble

class TradeItSelectBrokerViewControllerSpec: QuickSpec {

    class FakeTradeItConnector: TradeItConnector {
        let calls = InvocationStack()
        var completionBlock: (([AnyObject]!) -> Void)!

        override func getAvailableBrokersWithCompletionBlock(completionBlock: (([AnyObject]!) -> Void)!) {
            calls.invoke(#function, args: completionBlock)
            self.completionBlock = completionBlock
        }
    }

    override func spec() {
        var controller: TradeItSelectBrokerViewController!
        let tradeItConnector = FakeTradeItConnector()

        describe("initialization") {
            beforeEach {
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)

                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_SELECT_BROKER_VIEW") as! TradeItSelectBrokerViewController

                controller.tradeItConnector = tradeItConnector
                expect(controller.view).toNot(beNil())
            }

            it("fetches the available brokers") {
                expect(tradeItConnector.calls.forMethod("getAvailableBrokersWithCompletionBlock").count).to(equal(1))
            }

            it("shows a spinner") {
                expect(controller.activityIndicator.isAnimating()).to(beTrue())
            }

            context("when request to get brokers fails") {
                beforeEach {
                    tradeItConnector.completionBlock(nil)
                }

                it("hides the spinner") {
                    expect(controller.activityIndicator.isAnimating()).to(beFalse())
                }

                it("leaves the broker table empty") {
                    let brokerRowCount = controller.tableView(controller.brokerTable, numberOfRowsInSection: 0)
                    expect(brokerRowCount).to(equal(0))
                }

                it("shows an error alert") {
                    // TODO:
                }
            }

            context("when request to get brokers succeeds") {
                beforeEach {
                    let brokersResponse = [
                        ["longName": "Broker #1"],
                        ["longName": "Broker #2"]
                    ]

                    tradeItConnector.completionBlock(brokersResponse)
                }

                it("hides the spinner") {
                    expect(controller.activityIndicator.isAnimating()).to(beFalse())
                }

                it("populates the broker table") {
                    let brokerRowCount = controller.tableView(controller.brokerTable, numberOfRowsInSection: 0)
                    expect(brokerRowCount).to(equal(2))

                    var cell = controller.tableView(controller.brokerTable,
                                                          cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                    expect(cell.textLabel?.text).to(equal("Broker #1"))

                    cell = controller.tableView(controller.brokerTable,
                                                cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

                    expect(cell.textLabel?.text).to(equal("Broker #2"))
                }
            }
        }
    }
}