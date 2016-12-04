import UIKit
@testable import TradeItIosTicketSDK2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let API_KEY = "tradeit-fx-test-api-key" //"tradeit-test-api-key"
    static let ENVIRONMENT = TradeItEmsTestEnv
    var window: UIWindow?
    let tradeItLauncher: TradeItLauncher

    override init() {
        tradeItLauncher = TradeItLauncher(apiKey: AppDelegate.API_KEY, environment: AppDelegate.ENVIRONMENT)
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUITesting") {
            UIView.setAnimationsEnabled(false)
        }

        return true
    }

    func clearUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier;
        UserDefaults.standard.removePersistentDomain(forName: appDomain!);
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        guard url.scheme == "tradeitexample",
            url.host == "completeOAuth",
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems,
            let oAuthVerifier = queryItems.filter({ $0.name == "oAuthVerifier" }).first?.value
        else {
            print("=====> ERROR: Received unvalid deep link URL: \(url)")
            return false
        }

        TradeItLauncher.linkedBrokerManager.completeOAuthBrokerLinking(
            withOAuthVerifier: oAuthVerifier,
            onSuccess: { linkedBroker in
                print("=====> OAuth broker linking successful for \(linkedBroker.brokerName)!")

                if var topViewController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topViewController.presentedViewController {
                        topViewController = presentedViewController
                    }

                    if let navController = topViewController as? UINavigationController,
                        let exampleViewController = navController.topViewController as? ExampleViewController {
                        exampleViewController.oAuthFlowCompleted(withLinkedBroker: linkedBroker)
                    }
                }
            }, onFailure: { errorResult in
                print("=====> ERROR: OAuth broker linking failed! \(errorResult.errorCode()): \(errorResult.shortMessage): \(errorResult.longMessages?.first)")
            }
        )

        return true
    }
}
