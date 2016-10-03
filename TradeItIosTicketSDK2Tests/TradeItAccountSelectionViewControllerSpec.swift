import Quick
import Nimble

class TradeItAccountSelectionViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItAccountSelectionViewController!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var accountSelectionTableManager: FakeTradeItAccountSelectionTableViewManager!
        var window: UIWindow!
        var nav: UINavigationController!
        
        describe("initialization") {
            beforeEach {
                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                accountSelectionTableManager = FakeTradeItAccountSelectionTableViewManager()
                window = UIWindow()
                let bundle = TradeItBundleProvider.provide()
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                TradeItLauncher.linkedBrokerManager = linkedBrokerManager
                
                controller = storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.accountSelectionView.rawValue) as! TradeItAccountSelectionViewController
                
                controller.accountSelectionTableManager = accountSelectionTableManager
                
                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                
                flushAsyncEvents()
            }
            
            it("populate the table with the linkedBrokers") {
                expect(accountSelectionTableManager.calls.forMethod("updateLinkedBrokers(withLinkedBrokers:)").count).to(equal(1))
            }
        }
    }
    
}
