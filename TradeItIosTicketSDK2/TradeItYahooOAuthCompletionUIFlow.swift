import UIKit

public typealias OnOAuthCompletionSuccessHandler = ((
    _ presentedViewController: UIViewController,
    _ oAuthCallbackUrl: URL,
    _ linkedBroker: TradeItLinkedBroker?
) -> Void)

class TradeItYahooOAuthCompletionUIFlow: NSObject, TradeItYahooOAuthCompletionViewControllerDelegate {
    private let viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    private let linkBrokerUIFlow = TradeItYahooLinkBrokerUIFlow()

    private var onOAuthCompletionSuccessHandler: OnOAuthCompletionSuccessHandler?

    func presentOAuthCompletionFlow(
        fromViewController viewController: UIViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        onOAuthCompletionSuccessHandler: OnOAuthCompletionSuccessHandler? = nil
    ) {
        self.onOAuthCompletionSuccessHandler = onOAuthCompletionSuccessHandler

        let navController = TradeItYahooNavigationController()

        guard let oAuthCompletionViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooOAuthCompletionView) as? TradeItYahooOAuthCompletionViewController else {
            return print("TradeItSDK ERROR: Could not instantiate TradeItYahooOAuthCompletionViewController!")
        }

        oAuthCompletionViewController.delegate = self
        oAuthCompletionViewController.oAuthCallbackUrlParser = oAuthCallbackUrlParser
        navController.pushViewController(oAuthCompletionViewController, animated: false)
        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: TradeItOAuthCompletionViewControllerDelegate

    func onTryAgain(
        fromOAuthCompletionViewController viewController: TradeItYahooOAuthCompletionViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        linkedBroker: TradeItLinkedBroker?
    ) {
        guard let navController = viewController.navigationController else {
            return
        }

        let oAuthCallbackUrl = oAuthCallbackUrlParser.oAuthCallbackUrlWithoutOauthVerifier ?? TradeItSDK.oAuthCallbackUrl

        if let linkedBroker = linkedBroker ??
            TradeItSDK.linkedBrokerManager.getLinkedBroker(forUserId: oAuthCallbackUrlParser.relinkUserId) {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(
                inViewController: navController,
                linkedBroker: linkedBroker,
                oAuthCallbackUrl: oAuthCallbackUrl
            )
        } else {
            self.linkBrokerUIFlow.pushLinkBrokerFlow(
                onNavigationController: navController,
                asRootViewController: true,
                showWelcomeScreen: false,
                oAuthCallbackUrl: oAuthCallbackUrl
            )
        }
    }

    func onContinue(
        fromOAuthCompletionViewController viewController: TradeItYahooOAuthCompletionViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        linkedBroker: TradeItLinkedBroker?
    ) {
        self.onOAuthCompletionSuccessHandler?(
            viewController,
            oAuthCallbackUrlParser.oAuthCallbackUrl,
            linkedBroker
        )
    }
}
