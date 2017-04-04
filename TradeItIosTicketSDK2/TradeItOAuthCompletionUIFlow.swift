import UIKit

class TradeItOAuthCompletionUIFlow: NSObject, TradeItOAuthCompletionViewControllerDelegate {
    private let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    private let tradingUIFlow = TradeItTradingUIFlow()
    private let accountSelectionUIFlow = TradeItAccountSelectionUIFlow()
    private let linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    func presentOAuthCompletionFlow(fromViewController viewController: UIViewController,
                                    oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
                                    onSuccessfulLink: ((_ linkedBroker: TradeItLinkedBroker) -> Void)?) {
        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .oAuthCompletionView)

        if let oAuthCompletionViewController = navController.topViewController as? TradeItOAuthCompletionViewController {
            oAuthCompletionViewController.delegate = self
            oAuthCompletionViewController.oAuthCallbackUrlParser = oAuthCallbackUrlParser
            oAuthCompletionViewController.onSuccessfulLink = onSuccessfulLink
        }

        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: TradeItOAuthCompletionViewControllerDelegate

    func onTryAgain(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController,
                    oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
                    linkedBroker: TradeItLinkedBroker?) {
        guard let navController = viewController.navigationController else {
            return
        }

        let oAuthCallbackUrl = oAuthCallbackUrlParser.oAuthCallbackUrlWithoutOauthVerifier ?? TradeItSDK.oAuthCallbackUrl

        if let relinkUserId = oAuthCallbackUrlParser.relinkUserId {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(inViewController: navController,
                                                          userId: relinkUserId,
                                                          oAuthCallbackUrl: oAuthCallbackUrl)
        } else if let linkedBroker = linkedBroker {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(inViewController: navController,
                                                          linkedBroker: linkedBroker,
                                                          oAuthCallbackUrl: oAuthCallbackUrl)
        } else {
            self.linkBrokerUIFlow.pushLinkBrokerFlow(onNavigationController: navController,
                                                     asRootViewController: true,
                                                     showWelcomeScreen: false,
                                                     oAuthCallbackUrl: oAuthCallbackUrl)
        }
    }

    func onContinue(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController,
                    oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
                    linkedBroker: TradeItLinkedBroker?,
                    onSuccessfulLink: ((_ linkedBroker: TradeItLinkedBroker) -> Void)?) {

        guard let linkedBroker = linkedBroker else { return viewController.dismiss(animated: false) }

        onSuccessfulLink?(linkedBroker)

        guard let destination = oAuthCallbackUrlParser.destination else { return viewController.dismiss(animated: false) }

        switch destination {
        case .portfolio:
            let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .portfolioAccountsView)

            if let navController = viewController.navigationController {
                navController.setViewControllers([portfolioViewController], animated: true)
            }
        case .trading:
            if let navController = viewController.navigationController {
                self.tradingUIFlow.pushTradingFlow(onNavigationController: navController,
                                                   asRootViewController: true,
                                                   withOrder: oAuthCallbackUrlParser.order ?? TradeItOrder())
            }
        case .accountSelection:
            if let navController = viewController.navigationController {
                self.accountSelectionUIFlow.pushAccountSelectionFlow(
                    onNavigationController: navController,
                    title: TradeItLauncher.accountSelectionTitle,
                    onSelected: { presentedNavController, linkedBrokerAccount in
                        presentedNavController.dismiss(animated: true, completion: nil)
                        TradeItLauncher.accountSelectionCallback?(linkedBrokerAccount)
                    },
                    onFlowAborted: { presentedNavController in
                        presentedNavController.dismiss(animated: true, completion: nil)
                    }
                )
            }
        }
    }
}
