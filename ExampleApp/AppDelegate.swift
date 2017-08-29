import UIKit
import TradeItIosTicketSDK2


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let API_KEY = "tradeit-test-api-key" //"tradeit-test-api-key"
    static let ENVIRONMENT = TradeItEmsTestEnv
    var window: UIWindow?

    override init() {
        TradeItSDK.configure(
            apiKey: AppDelegate.API_KEY,
            oAuthCallbackUrl: URL(string: "tradeItExampleScheme://completeOAuth")!,
            environment: AppDelegate.ENVIRONMENT,
            userCountryCode: "US"
        )

        TradeItSDK.welcomeScreenHeadlineText = "This Welcome screen headline text is configurable in the SDK!"

        // To set a custom API base URL/host (only if you need the app to connect through a proxy/middle-tier):
        // TradeItSDK.set(host: "https://example.com:1234/myAPI/", forEnvironment: AppDelegate.ENVIRONMENT)

        super.init()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUITesting") {
            UIView.setAnimationsEnabled(false)
        }

        self.registerNotificationCenterObservers()

        return true
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any
    ) -> Bool {
        print("=====> Received OAuth callback URL: \(url.absoluteString)")

        let MANUAL_HOST = "manualCompleteOAuth"

        // Check for the intended url.scheme, url.host, and url.path before proceeding
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme == "tradeitexamplescheme",
            let host = urlComponents.host,
            let queryItems = urlComponents.queryItems,
            let oAuthVerifier = queryItems.filter({ $0.name == "oAuthVerifier" }).first?.value {

            if host == MANUAL_HOST {
                self.completeManualOAuth(oAuthVerifier: oAuthVerifier)
            } else {
                self.handleExampleOAuth(oAuthCallbackUrl: url, host: host)
            }
        } else {
            print("=====> ERROR: Received invalid OAuth callback URL: \(url.absoluteString)")
            return false
        }

        return true
    }

    // MARK: Private

    private func registerNotificationCenterObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLink),
            name: TradeItNotification.Name.didLink,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUnlink),
            name: TradeItNotification.Name.didUnlink,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onViewDidAppearNotification),
            name: TradeItNotification.Name.viewDidAppear,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onAlertShownNotification),
            name: TradeItNotification.Name.alertShown,
            object: nil
        )
    }

    func onAlertShownNotification(notification: Notification) {
        let view = notification.userInfo?[TradeItNotification.UserInfoKey.view] ?? "NO KEY FOR VIEW"
        let alertTitle = notification.userInfo?[TradeItNotification.UserInfoKey.alertTitle] ?? "NO KEY FOR ALERT TITLE"
        let alertMessage = notification.userInfo?[TradeItNotification.UserInfoKey.alertMessage] ?? "NO KEY FOR ALERT MESSAGE"
        print("=====> ALERT SHOWN: VIEW: \(view), TITLE: \(alertTitle), MESSAGE: \(alertMessage)")
    }

    func onViewDidAppearNotification(notification: Notification) {
        let view = notification.userInfo?[TradeItNotification.UserInfoKey.view] ?? "NO KEY FOR VIEW"
        let viewTitle = notification.userInfo?[TradeItNotification.UserInfoKey.viewTitle] ?? "NO KEY FOR VIEW TITLE"
        print("=====> VIEW APPEARED: \(view), TITLE: \(viewTitle)")
    }

    func didLink(notification: Notification) {
        print("TradeItSDK: didLink notification")
        guard let linkedBroker = notification.userInfo?["linkedBroker"] as? TradeItLinkedBroker else {
            return print("No linkedBroker passed with notification")
        }
        print(linkedBroker.brokerName)
    }

    func didUnlink(notification: Notification) {
        print("TradeItSDK: didUnlink notification")
        guard let linkedBroker = notification.userInfo?["linkedBroker"] as? TradeItLinkedBroker else {
            return print("No linkedBroker passed with notification")
        }
        print(linkedBroker.brokerName)
    }

    private func completeManualOAuth(oAuthVerifier: String) {
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
                        exampleViewController.oAuthFlowCompleted(withLinkedBroker: linkedBroker)
                    }
                }
            },
            onFailure: { errorResult in
                print("=====> ERROR: OAuth failed! \(String(describing: errorResult.errorCode)): \(String(describing: errorResult.shortMessage)): \(String(describing: errorResult.longMessages?.first))")
            }
        )
    }

    private func handleExampleOAuth(oAuthCallbackUrl: URL, host: String) {
        let EXAMPLE_HOST = "completeOAuth"
        let YAHOO_HOST = "completeYahooOAuth"

        if var topViewController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            if let navController = topViewController as? UINavigationController,
                let navTopViewController = navController.topViewController {
                topViewController = navTopViewController
            }

            switch host {
            case EXAMPLE_HOST:
                TradeItSDK.launcher.handleOAuthCallback(
                    onTopmostViewController: topViewController,
                    oAuthCallbackUrl: oAuthCallbackUrl
                )
            case YAHOO_HOST:
                TradeItSDK.yahooLauncher.handleOAuthCallback(
                    onTopmostViewController: topViewController,
                    oAuthCallbackUrl: oAuthCallbackUrl,
                    onOAuthCompletionSuccessHandler: { presentedViewController, oAuthCallbackUrl, linkedBroker in
                        print("=====> OAuth completion success for broker: [\(linkedBroker?.brokerName ?? "MISSING LINKED BROKER!!!")], callback URL: [\(oAuthCallbackUrl.absoluteString)]")
                    }
                )
            default:
                print("=====> ERROR: Received unknown OAuth callback URL host: \(host)")
            }
        }
    }
}

// Only implement this protocol if you need to inject your own market data
class DummyMarketDataService: MarketDataService {
    func getQuote(
        symbol: String,
        onSuccess: @escaping (TradeItQuote) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        // Get market data and populate TradeItQuote
        let quote = TradeItQuote()
        quote.companyName = "LOL"
        quote.lastPrice = 1337.42
        quote.change = 42.1337
        quote.pctChange = -123.456
        quote.dateTime = "12:34:56"
        onSuccess(quote)

        // OR if failed to get market data, create an error
        let error = TradeItErrorResult.error(withSystemMessage: "Some technical reason for failure")
        onFailure(error)
    }
}
