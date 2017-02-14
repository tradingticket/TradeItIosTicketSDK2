import UIKit
import TradeItIosTicketSDK2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let API_KEY = "tradeit-test-api-key" //"tradeit-fx-test-api-key"
    static let ENVIRONMENT = TradeItEmsTestEnv
    var window: UIWindow?

    override init() {
        TradeItSDK.configure(apiKey: AppDelegate.API_KEY,
                             oAuthCallbackUrl: URL(string: "tradeItExampleScheme://completeOAuth")!,
                             environment: AppDelegate.ENVIRONMENT)
        super.init()
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUITesting") {
            UIView.setAnimationsEnabled(false)
        }

        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {

        let EXAMPLE_HOST = "completeOAuth"

        // Check for the intended url.scheme, url.host, and url.path before proceeding
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme == "tradeitexamplescheme",
            let host = urlComponents.host,
            let queryItems = urlComponents.queryItems,
            let oAuthVerifier = queryItems.filter({ $0.name == "oAuthVerifier" }).first?.value {

            if host == EXAMPLE_HOST {
                self.handleExampleOAuth(oAuthCallbackUrl: url)
            } else {
                self.completeManualOAuth(oAuthVerifier: oAuthVerifier, host: host)
            }
        } else {
            print("=====> ERROR: Received invalid OAuth callback URL: \(url)")
            return false
        }

        return true
    }

    // MARK: Private

    private func completeManualOAuth(oAuthVerifier: String, host: String) {
        let MANUAL_HOST = "manualCompleteOAuth"
        let YAHOO_HOST = "completeYahooOAuth"

        // TODO: Move this into exampleViewController.oAuthFlowCompleted
        TradeItSDK.linkedBrokerManager.completeOAuth(
            withOAuthVerifier: oAuthVerifier,
            onSuccess: { linkedBroker in
                print("=====> OAuth successful for \(linkedBroker.brokerName)!")

                if var topViewController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topViewController.presentedViewController {
                        topViewController = presentedViewController
                    }

                    if let navController = topViewController as? UINavigationController,
                        let exampleViewController = navController.topViewController as? ExampleViewController {
                        switch host {
                        case MANUAL_HOST:
                            exampleViewController.oAuthFlowCompleted(withLinkedBroker: linkedBroker)
                        case YAHOO_HOST:
                            exampleViewController.yahooOAuthFlowCompleted(withLinkedBroker: linkedBroker)
                        default:
                            print("=====> ERROR: Received unknown OAuth callback URL host: \(host)")
                        }
                    }
                }
            },
            onFailure: { errorResult in
                print("=====> ERROR: OAuth failed! \(errorResult.errorCode()): \(errorResult.shortMessage): \(errorResult.longMessages?.first)")
            }
        )
    }

    private func handleExampleOAuth(oAuthCallbackUrl: URL) {
        if var topViewController = UIApplication.shared.keyWindow?.rootViewController {

            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            if let navController = topViewController as? UINavigationController,
                let navTopViewController = navController.topViewController {
                topViewController = navTopViewController
            }

            TradeItSDK.launcher.handleOAuthCallback(onViewController: topViewController, oAuthCallbackUrl: oAuthCallbackUrl)
        }
    }
}
