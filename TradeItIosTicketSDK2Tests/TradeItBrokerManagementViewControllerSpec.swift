import Quick
import Nimble
@testable import TradeItIosTicketSDK2

class TradeItBrokerManagementViewControllerSpec: QuickSpec {

    override func spec() {
        var controller: TradeItBrokerManagementViewController!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
         var brokerManagementTableManager: FakeTradeItBrokerManagementTableViewManager!
        var window: UIWindow!
        var nav: UINavigationController!
        
        xdescribe("initialization") {
            beforeEach {
                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                brokerManagementTableManager = FakeTradeItBrokerManagementTableViewManager()
                window = UIWindow()
                let bundle = Bundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                TradeItSDK._linkedBrokerManager = linkedBrokerManager
                
                controller = storyboard.instantiateViewController(withIdentifier: TradeItStoryboardID.brokerManagementView.rawValue) as! TradeItBrokerManagementViewController
                
                controller.brokerManagementTableManager = brokerManagementTableManager
                
                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                
                flushAsyncEvents()
            }
            
            it("populate the table with the linkedBrokers") {
                expect(brokerManagementTableManager.calls.forMethod("updateLinkedBrokers(withLinkedBrokers:)").count).to(equal(1))
            }
        }
    }
}
