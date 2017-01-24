import UIKit

class TradeItYahooTradingUIFlow: NSObject, TradeItYahooTradingTicketViewControllerDelegate, TradeItYahooAccountSelectionViewControllerDelegate {

    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var order = TradeItOrder()
    
    func presentTradingFlow(fromViewController viewController: UIViewController,
                            withOrder order: TradeItOrder = TradeItOrder()) {
        self.order = order
        
        let navController = UINavigationController()
        
        let initialViewController = getInitialViewController(forOrder: order)
        
        navController.setViewControllers([initialViewController], animated: true)
        
        viewController.present(navController, animated: true, completion: nil)
    }
    
    // MARK: Private
    
    private func initializeLinkedAccount(forOrder order: TradeItOrder) {
        if order.linkedBrokerAccount == nil {
            let enabledAccounts = TradeItSDK.linkedBrokerManager.getAllEnabledAccounts()
            if enabledAccounts.count == 1 {
                order.linkedBrokerAccount = enabledAccounts.first
            }
        }
    }

    private func getInitialViewController(forOrder order: TradeItOrder) -> UIViewController {
        var initialStoryboardId: TradeItStoryboardID!
        
        self.initializeLinkedAccount(forOrder: order)

        if (order.linkedBrokerAccount == nil) {
            initialStoryboardId = TradeItStoryboardID.yahooAccountSelectionView
        } else {
            initialStoryboardId = TradeItStoryboardID.yahooTradingTicketView
        }
        
        let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: initialStoryboardId)
        
        if let accountSelectionViewController = initialViewController as? TradeItYahooAccountSelectionViewController {
            accountSelectionViewController.delegate = self
        } else if let tradingTicketViewController = initialViewController as? TradeItYahooTradingTicketViewController {
            tradingTicketViewController.delegate = self
            tradingTicketViewController.order = order
        }
        
        return initialViewController
    }

    // MARK: TradeItYahooAccountSelectionViewControllerDelegate
    internal func accountSelectionViewController(_ accountSelectionViewController: TradeItYahooAccountSelectionViewController,
                                                 didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.order.linkedBrokerAccount = linkedBrokerAccount

        if let tradingTicketViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooTradingTicketView) as? TradeItYahooTradingTicketViewController {
            tradingTicketViewController.delegate = self
            tradingTicketViewController.order = order
            accountSelectionViewController.navigationController?.setViewControllers([tradingTicketViewController], animated: true)
        }
    }
}
