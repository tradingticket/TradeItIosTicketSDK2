import UIKit

class TradeItAccountSelectionUIFlow: NSObject, TradeItAccountSelectionViewControllerDelegate {
    let viewControllerProvider = TradeItViewControllerProvider()
    var onSelectedCallback: ((_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void)?
    var onFlowAbortedCallback: ((_ presentedNavController: UINavigationController) -> Void)?

    func presentAccountSelectionFlow(fromViewController viewController: UIViewController,
                                     title: String? = nil,
                                     onSelected: @escaping (_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void,
                                     onFlowAborted: @escaping (_ presentedNavController: UINavigationController) -> Void) {
        self.onSelectedCallback = onSelected
        self.onFlowAbortedCallback = onFlowAborted

        let navController = viewControllerProvider.provideNavigationController(withRootViewStoryboardId: .accountSelectionView)

        if let accountSelectionViewController = navController.viewControllers[0] as? TradeItAccountSelectionViewController {
            accountSelectionViewController.delegate = self
            accountSelectionViewController.promptText = title
        }

        viewController.present(navController, animated: true)
    }

    func pushAccountSelectionFlow(onNavigationController navController: UINavigationController,
                                  title: String? = nil,
                                  onSelected: @escaping (_ presentedNavController: UINavigationController, _ linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Void,
                                  onFlowAborted: @escaping (_ presentedNavController: UINavigationController) -> Void) {
        self.onSelectedCallback = onSelected
        self.onFlowAbortedCallback = onFlowAborted

        let accountSelectionViewController = viewControllerProvider.provideViewController(forStoryboardId: .accountSelectionView) as? TradeItAccountSelectionViewController
        accountSelectionViewController?.delegate = self
        accountSelectionViewController?.promptText = title

        navController.setViewControllers([accountSelectionViewController!], animated: true)
    }

    func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController, didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.onSelectedCallback?(accountSelectionViewController.navigationController!, linkedBrokerAccount)
    }
}
