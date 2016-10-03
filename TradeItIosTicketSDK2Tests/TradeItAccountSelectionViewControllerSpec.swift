import Quick
import Nimble
import TradeItIosEmsApi

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
                
                let linkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                let account1 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My Special Broker", accountName: "My account #1", accountNumber: "123456789", balance: nil, fxBalance: nil, positions: [])
                let account2 = FakeTradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My Special Broker", accountName: "My account #2", accountNumber: "234567890", balance: nil, fxBalance: nil, positions: [])
                linkedBroker.accounts = [account1, account2]
                linkedBrokerManager.linkedBrokers = [linkedBroker]
                
                nav = UINavigationController(rootViewController: controller)
                
                window.addSubview(nav.view)
                
                flushAsyncEvents()
            }
            
            it("populate the table with the linkedBrokers") {
                expect(accountSelectionTableManager.calls.forMethod("updateLinkedBrokers(withLinkedBrokers:)").count).to(equal(1))
            }
            
            describe("pull to refresh") {
                var onRefreshCompleteWasCalled = false
                var linkedBrokersArg: [TradeItLinkedBroker]?
                beforeEach {
                    let onRefreshComplete: ([TradeItLinkedBroker]?)-> Void = { (withLinkedBrokers: [TradeItLinkedBroker]?) in
                        onRefreshCompleteWasCalled = true
                        linkedBrokersArg = withLinkedBrokers
                    }
                    accountSelectionTableManager.calls.reset()
                    controller.refreshRequested(fromAccountSelectionTableViewManager: accountSelectionTableManager, onRefreshComplete: onRefreshComplete)
                    
                }
                
                it("reauthenticates all the linkedBrokers") {
                    expect(linkedBrokerManager.calls.forMethod("authenticateAll(onSecurityQuestion:onFinished:)").count).to(equal(1))
                }
                
                context("when authentication call finished") {
                    beforeEach {
                        let onFinished = linkedBrokerManager.calls.forMethod("authenticateAll(onSecurityQuestion:onFinished:)")[0].args["onFinished"] as! () -> Void
                        onFinished()
                    }
                    
                    it("calls refreshAccountBalances on the linkedBrokerManager") {
                        expect(linkedBrokerManager.calls.forMethod("refreshAccountBalances(onFinished:)").count).to(equal(1))
                    }
                    
                    describe("when finishing to refresh balances") {
                        beforeEach {
                            let onFinished1 = linkedBrokerManager.calls.forMethod("refreshAccountBalances(onFinished:)")[0].args["onFinished"] as! () -> Void
                            onFinished1()
                        }
                        
                        it("calls onRefreshComplete with the linked Brokers") {
                            expect(onRefreshCompleteWasCalled).to(beTrue())
                            expect(linkedBrokersArg).to(equal(linkedBrokerManager.linkedBrokers))
                        }
                    }
                }
                
                context("when there is a security question") {
                    //TODO
                }
            }

        }
    }
    
}
