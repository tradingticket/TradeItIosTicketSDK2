import UIKit

class TradeItAccountSelectionUIFlow: NSObject, TradeItAccountSelectionViewControllerDelegate {
    let viewControllerProvider = TradeItViewControllerProvider()
    var onSelectedCallback: ((_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void)?
    var onFlowAbortedCallback: ((_ presentedNavController: UINavigationController) -> Void)?

    func presentAccountSelectionFlow(fromViewController viewController: UIViewController,
                                     onSelected: @escaping (_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void,
                                     onFlowAborted: @escaping (_ presentedNavController: UINavigationController) -> Void) {
        self.onSelectedCallback = onSelected
        self.onFlowAbortedCallback = onFlowAborted

        let navController = viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .accountSelectionView)

        if let rootViewController = navController.viewControllers[0] as? TradeItAccountSelectionViewController {
            rootViewController.delegate = self
        }

        viewController.present(navController, animated: true)
    }

    func pushAccountSelectionFlow(onNavigationController navController: UINavigationController,
                                     onSelected: @escaping (_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void,
                                     onFlowAborted: @escaping (_ presentedNavController: UINavigationController) -> Void) {
        self.onSelectedCallback = onSelected
        self.onFlowAbortedCallback = onFlowAborted

        let accountSelectionViewController = viewControllerProvider.provideViewController(forStoryboardId: .accountSelectionView) as? TradeItAccountSelectionViewController
        accountSelectionViewController?.delegate = self

        navController.setViewControllers([accountSelectionViewController!], animated: true)
    }

    func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController, didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.onSelectedCallback?(accountSelectionViewController.navigationController!, linkedBrokerAccount)
    }
}
