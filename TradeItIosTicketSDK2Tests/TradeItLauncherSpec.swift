import Quick
import Nimble
@testable import TradeItIosTicketSDK2

class TradeItLauncherSpec: QuickSpec {
    override func spec() {
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var deviceManager: FakeTradeItDeviceManager!
        var viewController: UIViewController!
        var window: UIWindow!
        
        describe("TradeItLauncher") {
            beforeEach {
                window = UIWindow()
                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                deviceManager = FakeTradeItDeviceManager()

                TradeItSDK.configure(apiKey: "my-special-api-key", environment: TradeItEmsTestEnv)
                TradeItSDK.launcher.deviceManager = deviceManager

                TradeItSDK._linkedBrokerManager = linkedBrokerManager

                viewController = UIViewController()

                expect(viewController.view).notTo(beNil())
                window.addSubview(viewController.view)

            }

            describe("launchPortfolio(fromViewController:)") {
                context("when there are no linked brokers") {
                    it("presents the Trade It Welcome view") {
                        TradeItSDK.launcher.launchPortfolio(fromViewController: viewController)

                        let navViewController = viewController.presentedViewController as! UINavigationController
                        expect(navViewController.navigationBar.topItem!.title).to(equal("Welcome"))
                    }
                }

                context("when there are linked brokers") {
                    it("presents the Trade It Portfolio view") {
                        let linkedBroker = TradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
                        linkedBrokerManager.linkedBrokers = [linkedBroker]

                        TradeItSDK.launcher.launchPortfolio(fromViewController: viewController)

                        let navViewController = viewController.presentedViewController as! UINavigationController
                        expect(navViewController.navigationBar.topItem!.title).to(equal("Portfolio"))
                    }
                }
            }
        }
    }
}
