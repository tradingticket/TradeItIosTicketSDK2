import Quick
import Nimble
@testable import TradeItIosTicketSDK2

class TradeItSelectBrokerViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItSelectBrokerViewController!
        var window: UIWindow!
        var nav: UINavigationController!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var tradeItConnector: FakeTradeItConnector!
//        var ezLoadingActivityManager: FakeEZLoadingActivityManager!
        var delegate: FakeTradeItSelectBrokerViewControllerDelegate!
        
        describe("initialization") {
            beforeEach {
                tradeItConnector = FakeTradeItConnector()
                delegate = FakeTradeItSelectBrokerViewControllerDelegate()
                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                linkedBrokerManager.tradeItConnector = tradeItConnector
                linkedBrokerManager.tradeItSessionProvider = FakeTradeItSessionProvider()
                TradeItLauncher.linkedBrokerManager = linkedBrokerManager

                window = UIWindow()
                let bundle = Bundle(identifier: "TradeIt.TradeItIosTicketSDK2")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)

                controller = storyboard.instantiateViewController(withIdentifier: TradeItStoryboardID.selectBrokerView.rawValue) as! TradeItSelectBrokerViewController
                
//                ezLoadingActivityManager = FakeEZLoadingActivityManager()
//                controller.ezLoadingActivityManager = ezLoadingActivityManager
                controller.delegate = delegate
                nav = UINavigationController(rootViewController: controller)

                expect(controller.view).toNot(beNil())
                expect(nav.view).toNot(beNil())

                window.addSubview(nav.view)

                flushAsyncEvents()
            }

            it("fetches the available brokers") {
                expect(linkedBrokerManager.calls.forMethod("getAvailableBrokers(onSuccess:onFailure:)").count).to(equal(1))
            }

//            it("shows a spinner") {
//                expect(ezLoadingActivityManager.spinnerIsShowing).to(beTrue())
//                expect(ezLoadingActivityManager.spinnerText).to(equal("Loading Brokers"))
//            }

            context("when request to get brokers fails") {
                beforeEach {
                    let completionHandler = linkedBrokerManager.calls.forMethod("getAvailableBrokers(onSuccess:onFailure:)")[0].args["onFailure"] as! (() -> Void)
                    completionHandler()
                }

//                it("hides the spinner") {
//                    expect(ezLoadingActivityManager.spinnerIsShowing).to(beFalse())
//                }

                it("leaves the broker table empty") {
                    let brokerRowCount = controller.tableView(controller.brokerTable, numberOfRowsInSection: 0)
                    expect(brokerRowCount).to(equal(0))
                }

                xit("shows an error alert") {
                    expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController.self))
                    expect(controller.presentedViewController?.title).to(equal("Could not fetch brokers"))
                }
            }

            context("when request to get brokers succeeds") {
                beforeEach {
                    let broker1 = TradeItBroker(shortName: "Broker Short #1", longName: "Broker Long #1")
                    let broker2 = TradeItBroker(shortName: "Broker Short #2", longName: "Broker Long #2")
                    let brokersResponse = [broker1!, broker2!]

                    let completionHandler = linkedBrokerManager.calls.forMethod("getAvailableBrokers(onSuccess:onFailure:)")[0].args["onSuccess"] as! (([TradeItBroker]) -> Void)
                    completionHandler(brokersResponse)
                }

//                it("hides the spinner") {
//                    expect(ezLoadingActivityManager.spinnerIsShowing).to(beFalse())
//                }

                it("populates the broker table") {
                    let brokerRowCount = controller.tableView(controller.brokerTable, numberOfRowsInSection: 0)
                    expect(brokerRowCount).to(equal(2))

                    var cell = controller.tableView(controller.brokerTable,
                                                          cellForRowAt: IndexPath(row: 0, section: 0))

                    expect(cell.textLabel?.text).to(equal("Broker Long #1"))

                    cell = controller.tableView(controller.brokerTable,
                                                cellForRowAt: IndexPath(row: 1, section: 0))

                    expect(cell.textLabel?.text).to(equal("Broker Long #2"))
                }

                describe("choosing a broker") {
                    beforeEach {
                        controller.tableView(controller.brokerTable, didSelectRowAt: IndexPath(row: 1, section: 0))
                    }

                    it("calling brokerWasSelected on the delegate") {
                        let calls = delegate.calls.forMethod("brokerWasSelected(_:broker:)")
                        let arg1 = calls[0].args["fromSelectBrokerViewController"] as! TradeItSelectBrokerViewController
                        let arg2 = calls[0].args["broker"] as! TradeItBroker
                        
                        expect(calls.count).to(equal(1))
                        expect(arg1).to(equal(controller))
                        expect(arg2).to(equal(controller.selectedBroker))
                    }
                }
            }
        }
    }
}
