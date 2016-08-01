import Quick
import Nimble

class TradeItLauncherSpec : QuickSpec {
    override func spec() {
        var tradeItLauncher: TradeItLauncher!
        var viewController: UIViewController!

        describe("TradeItLauncher") {
            beforeEach {
                tradeItLauncher = TradeItLauncher()
                viewController = UIViewController()

                expect(viewController.view).notTo(beNil())
            }

            describe("launchTradeItFromViewController") {
                it("presents the Trade It nav view controller") {
                    tradeItLauncher.launchTradeItFromViewController(viewController)
                }
            }
        }
    }
}