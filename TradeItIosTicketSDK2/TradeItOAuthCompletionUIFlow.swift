import UIKit

class TradeItOAuthCompletionUIFlow: NSObject, TradeItOAuthCompletionViewControllerDelegate {
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser?
    let tradingUIFlow = TradeItTradingUIFlow()

    func presentOAuthCompletionFlow(fromViewController viewController: UIViewController,
                                    withOAuthCallbackUrlParser oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser) {
        self.oAuthCallbackUrlParser = oAuthCallbackUrlParser

        let navController = self.viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .oAuthCompletionView)

        if let oAuthCallbackViewController = navController.topViewController as? TradeItOAuthCompletionViewController {
            oAuthCallbackViewController.delegate = self
            oAuthCallbackViewController.oAuthCallbackUrlParser = oAuthCallbackUrlParser
        }

        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: TradeItOAuthCompletionViewControllerDelegate

    func continueButtonTapped(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController, linkedBroker: TradeItLinkedBroker?) {

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
            // TradeItSDK.launcher.launchPortfolio(fromViewController: viewController)
        case .trading:
            if let navController = viewController.navigationController {
                self.tradingUIFlow.pushTradingFlow(onNavigationController: navController,
                                                   asRootViewController: true,
                                                   withOrder: self.oAuthCallbackUrlParser?.order ?? TradeItOrder())
            }
        default:
            viewController.dismiss(animated: false)
        }
    }
}
