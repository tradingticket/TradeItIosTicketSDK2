import Quick
import Nimble

class TradeItLauncherSpec : QuickSpec {
    override func spec() {
        var tradeItLauncher: TradeItLauncher!
        var viewController: UIViewController!
        var window: UIWindow!
        
        describe("TradeItLauncher") {
            beforeEach {
                window = UIWindow()
                tradeItLauncher = TradeItLauncher(withEnvironment: TradeItEmsTestEnv)
                viewController = UIViewController()

                expect(viewController.view).notTo(beNil())
                window.addSubview(viewController.view)
            }

            describe("launchTradeItFromViewController") {
                it("presents the Trade It nav view controller") {
                    tradeItLauncher.launchTradeItFromViewController(viewController)
                }
            }
        }
    }
}