import UIKit

class TradeItOAuthCompletionUIFlow: NSObject, TradeItOAuthCompletionViewControllerDelegate {
    private let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    private let equityTradingUIFlow = TradeItEquityTradingUIFlow()
    private let fxTradingUIFlow = TradeItFxTradingUIFlow()
    private let accountSelectionUIFlow = TradeItAccountSelectionUIFlow()
    private let linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    func presentOAuthCompletionFlow(
        fromViewController viewController: UIViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser
    ) {
        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .oAuthCompletionView)

        if let oAuthCompletionViewController = navController.topViewController as? TradeItOAuthCompletionViewController {
            oAuthCompletionViewController.delegate = self
            oAuthCompletionViewController.oAuthCallbackUrlParser = oAuthCallbackUrlParser
        }

        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: TradeItOAuthCompletionViewControllerDelegate

    func onTryAgain(
        fromOAuthCompletionViewController viewController: TradeItOAuthCompletionViewController,
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
        fromOAuthCompletionViewController viewController: TradeItOAuthCompletionViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        linkedBroker: TradeItLinkedBroker?
    ) {
        guard let destination = oAuthCallbackUrlParser.destination else { return viewController.dismiss(animated: false) }

        switch destination {
        case .portfolio:
            let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .portfolioAccountsView)

            if let navController = viewController.navigationController {
                navController.setViewControllers([portfolioViewController], animated: true)
            }
        case .trading:
            if let navController = viewController.navigationController {
                self.equityTradingUIFlow.pushTradingFlow(
                    onNavigationController: navController,
                    asRootViewController: true,
                    withOrder: oAuthCallbackUrlParser.order ?? TradeItOrder()
                )
            }
        case .fxTrading:
            if let navController = viewController.navigationController {
                // TODO fix this up to generate an FxOrder from params
                self.fxTradingUIFlow.pushTradingFlow(
                    onNavigationController: navController,
                    asRootViewController: true,
                    withOrder: TradeItFxOrder()
                )
            }
        case .cryptoTrading:
            // TODO
            break
        case .accountSelection:
            if let navController = viewController.navigationController {
                self.accountSelectionUIFlow.pushAccountSelectionFlow(
                    onNavigationController: navController,
                    title: TradeItLauncher.accountSelectionTitle,
                    onSelected: { presentedNavController, linkedBrokerAccount in
                        presentedNavController.dismiss(animated: true, completion: nil)
                        TradeItLauncher.accountSelectionCallback?(linkedBrokerAccount)
                    }
                )
            }
        }
    }
}
