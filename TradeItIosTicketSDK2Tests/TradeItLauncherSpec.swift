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


//                let storyboard = UIStoryboard(name: "TestHarness", bundle: NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests"))
//                viewController = storyboard.instantiateViewControllerWithIdentifier("TestHarnessViewController") as UIViewController

                let window = UIWindow(frame: UIScreen.mainScreen().bounds)
                window.rootViewController = viewController
                window.makeKeyAndVisible()

                expect(viewController.view).notTo(beNil())


            }

            describe("launchTradeItFromViewController") {
                it("presents the Trade It nav view controller") {
                    tradeItLauncher.launchTradeItFromViewController(viewController)
                    expect(viewController.presentedViewController).toEventually(beAnInstanceOf(UINavigationController))
                }
            }
        }
    }
}