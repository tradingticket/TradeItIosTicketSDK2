import UIKit

class TradeItAccountSelectionUIFlow: NSObject, TradeItAccountSelectionViewControllerDelegate {
    let viewControllerProvider = TradeItViewControllerProvider()
    var onSelectedCallback: ((_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void)?

    func presentAccountSelectionFlow(
        fromViewController viewController: UIViewController,
        title: String? = nil,
        onSelected: @escaping (_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void
    ) {
        self.onSelectedCallback = onSelected

        let navController = viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .accountSelectionView)

        if let accountSelectionViewController = navController.viewControllers[0] as? TradeItAccountSelectionViewController {
            accountSelectionViewController.delegate = self
            accountSelectionViewController.promptText = title
        }

        viewController.present(navController, animated: true)
    }

    func pushAccountSelectionFlow(
        onNavigationController navController: UINavigationController,
        title: String? = nil,
        asRootViewController: Bool = false,
        onSelected: @escaping (_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void
    ) {
        self.onSelectedCallback = onSelected

        if let accountSelectionViewController = viewControllerProvider.provideViewController(forStoryboardId: .accountSelectionView) as? TradeItAccountSelectionViewController {
            accountSelectionViewController.delegate = self
            accountSelectionViewController.promptText = title

            if (asRootViewController) {
                navController.setViewControllers([accountSelectionViewController], animated: true)
            } else {
                navController.pushViewController(accountSelectionViewController, animated: true)
            }
        }
    }

    // MARK: TradeItAccountSelectionViewControllerDelegate

    func accountSelectionViewController(
        _ accountSelectionViewController: TradeItAccountSelectionViewController,
        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount
    ) {
        self.onSelectedCallback?(accountSelectionViewController.navigationController!, linkedBrokerAccount)
    }
}
