import UIKit

class TradeItTradingUIFlow: NSObject, TradeItAccountSelectionViewControllerDelegate, TradeItSymbolSearchViewControllerDelegate {
    let linkedBrokerManager: TradeItLinkedBrokerManager
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItOrder()

    init(linkedBrokerManager: TradeItLinkedBrokerManager) {
        self.linkedBrokerManager = linkedBrokerManager
    }

    func pushTradingFlow(onNavigationController navController: UINavigationController,
                                                asRootViewController: Bool,
                                                withOrder order: TradeItOrder = TradeItOrder()) {
        self.order = order

        let initialViewController = getInitialViewController(forOrder: order)

        if (asRootViewController) {
            navController.setViewControllers([initialViewController], animated: true)
        } else {
            navController.pushViewController(initialViewController, animated: true)
        }
    }

    func presentTradingFlow(fromViewController viewController: UIViewController,
                            withOrder order: TradeItOrder = TradeItOrder()) {
        self.order = order

        let navController = UINavigationController()

        let initialViewController = getInitialViewController(forOrder: order)

        navController.setViewControllers([initialViewController], animated: true)

        viewController.presentViewController(navController, animated: true, completion: nil)
    }

    // MARK: Private

    func initializeLinkedAccount(forOrder order: TradeItOrder) {
        let enabledAccounts = self.linkedBrokerManager.getAllEnabledAccounts()

        if (enabledAccounts.count == 1) {
            order.linkedBrokerAccount = enabledAccounts.first
        }
    }

    func getInitialViewController(forOrder order: TradeItOrder) -> UIViewController {
        var initialStoryboardId: TradeItStoryboardID!

        self.initializeLinkedAccount(forOrder: order)

        if (order.linkedBrokerAccount == nil) {
            initialStoryboardId = TradeItStoryboardID.accountSelectionView
        } else if (order.symbol == nil) {
            initialStoryboardId = TradeItStoryboardID.symbolSearchView
        } else {
            initialStoryboardId = TradeItStoryboardID.tradingTicketView
        }

        let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: initialStoryboardId)

        if let accountSelectionViewController = initialViewController as? TradeItAccountSelectionViewController {
            accountSelectionViewController.delegate = self
        } else if let symbolSearchViewController = initialViewController as? TradeItSymbolSearchViewController {
            symbolSearchViewController.delegate = self
        } else if let tradingTicketViewController = initialViewController as? TradeItTradingTicketViewController {
            tradingTicketViewController.order = order
        }

        return initialViewController
    }

    // MARK: TradeItSymbolSearchViewControllerDelegate

    func symbolSearchViewController(symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String) {
        self.order.symbol = selectedSymbol

        let tradingTicketViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.tradingTicketView) as! TradeItTradingTicketViewController

        tradingTicketViewController.order = self.order

        symbolSearchViewController.navigationController?.setViewControllers([tradingTicketViewController], animated: true)
    }

    func symbolSearchCancelled(forSymbolSearchViewController symbolSearchViewController: TradeItSymbolSearchViewController) {

    }


    // MARK: TradeItAccountSelectionViewControllerDelegate

    func accountSelectionViewController(accountSelectionViewController: TradeItAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.order.linkedBrokerAccount = linkedBrokerAccount

        var nextStoryboardId: TradeItStoryboardID!

        if (order.symbol == nil) {
            nextStoryboardId = TradeItStoryboardID.symbolSearchView
        } else {
            nextStoryboardId = TradeItStoryboardID.tradingTicketView
        }

        let nextViewController = self.viewControllerProvider.provideViewController(forStoryboardId: nextStoryboardId)

        if let symbolSearchViewController = nextViewController as? TradeItSymbolSearchViewController {
            symbolSearchViewController.delegate = self
        } else if let tradingTicketViewController = nextViewController as? TradeItTradingTicketViewController {
            tradingTicketViewController.order = self.order
        }

        accountSelectionViewController.navigationController?.setViewControllers([nextViewController], animated: true)
    }

    func accountSelectionCancelled(forAccountSelectionViewController accountSelectionViewController: TradeItAccountSelectionViewController) {

    }
}
