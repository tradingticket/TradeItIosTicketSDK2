import UIKit

class TradeItOAuthCompletionUIFlow: NSObject, TradeItOAuthCompletionViewControllerDelegate {
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser?
    let tradingUIFlow = TradeItTradingUIFlow()
    let accountSelectionUIFlow = TradeItAccountSelectionUIFlow()
    let linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    func presentOAuthCompletionFlow(fromViewController viewController: UIViewController,
                                    withOAuthCallbackUrlParser oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser) {
        self.oAuthCallbackUrlParser = oAuthCallbackUrlParser

        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .oAuthCompletionView)

        if let oAuthCompletionViewController = navController.topViewController as? TradeItOAuthCompletionViewController {
            oAuthCompletionViewController.delegate = self
            oAuthCompletionViewController.oAuthCallbackUrlParser = oAuthCallbackUrlParser
        }

        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: TradeItOAuthCompletionViewControllerDelegate

    func onTryAgain(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController) {
        guard let navController = viewController.navigationController else {
            return
        }

        let oAuthCallbackUrl = self.oAuthCallbackUrlParser?.oAuthCallbackUrlWithoutOauthVerifier ?? TradeItSDK.oAuthCallbackUrl

        self.linkBrokerUIFlow.pushLinkBrokerFlow(onNavigationController: navController,
                                                 asRootViewController: true,
                                                 showWelcomeScreen: false,
                                                 oAuthCallbackUrl: oAuthCallbackUrl)
    }

    func onContinue(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController,
                    linkedBroker: TradeItLinkedBroker?) {

        guard linkedBroker != nil,
            let destination = self.oAuthCallbackUrlParser?.destination
        else {
            viewController.dismiss(animated: false)
            return
        }

        switch destination {
        case .portfolio:
            let portfolioViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .portfolioView)

            if let navController = viewController.navigationController {
                navController.setViewControllers([portfolioViewController], animated: true)
            }
        case .trading:
            if let navController = viewController.navigationController {
                self.tradingUIFlow.pushTradingFlow(onNavigationController: navController,
                                                   asRootViewController: true,
                                                   withOrder: self.oAuthCallbackUrlParser?.order ?? TradeItOrder())
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
        default:
            viewController.dismiss(animated: false)
        }
    }
}
