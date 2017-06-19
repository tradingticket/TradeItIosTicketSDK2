import UIKit

class TradeItFxTradingUIFlow: NSObject, TradeItAccountSelectionViewControllerDelegate, TradeItFxTradingTicketViewControllerDelegate {
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItFxOrder()

    func pushTradingFlow(onNavigationController navController: UINavigationController,
                         asRootViewController: Bool,
                         withOrder order: TradeItFxOrder = TradeItFxOrder()) {
        self.order = order

        let initialViewController = getInitialViewController(forOrder: order)
        if (asRootViewController) {
            navController.setViewControllers([initialViewController], animated: true)
        } else {
            navController.pushViewController(initialViewController, animated: true)
        }
    }

    func presentTradingFlow(fromViewController viewController: UIViewController,
                            withOrder order: TradeItFxOrder = TradeItFxOrder()) {
        self.order = order

        let initialViewController = getInitialViewController(forOrder: order)

        let navController = UINavigationController()
        navController.setViewControllers([initialViewController], animated: true)

        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: Private

    private func getInitialViewController(forOrder order: TradeItFxOrder) -> UIViewController {
        var initialStoryboardId: TradeItStoryboardID!

        self.initializeLinkedAccount(forOrder: order)
        // TODO: Initialize order.symbol

        if (order.linkedBrokerAccount == nil) {
            initialStoryboardId = TradeItStoryboardID.accountSelectionView
        } else {
            initialStoryboardId = TradeItStoryboardID.fxTradingTicketView
        }

        let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: initialStoryboardId)

        if let accountSelectionViewController = initialViewController as? TradeItAccountSelectionViewController {
            accountSelectionViewController.delegate = self
        } else if let tradingTicketViewController = initialViewController as? TradeItFxTradingTicketViewController {
            tradingTicketViewController.delegate = self
            tradingTicketViewController.order = order
        }

        return initialViewController
    }

    private func initializeLinkedAccount(forOrder order: TradeItFxOrder) {
        if order.linkedBrokerAccount == nil {
            let enabledAccounts = TradeItSDK.linkedBrokerManager.getAllEnabledAccounts()

            // If there is only one enabled account, auto-select it
            if enabledAccounts.count == 1 {
                order.linkedBrokerAccount = enabledAccounts.first
            }
        }
    }

    // MARK: TradeItAccountSelectionViewControllerDelegate

    internal func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController,
                                                 didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.order.linkedBrokerAccount = linkedBrokerAccount

        var nextStoryboardId: TradeItStoryboardID!

        if (order.symbol == nil) {
            nextStoryboardId = TradeItStoryboardID.symbolSearchView
        } else {
            nextStoryboardId = TradeItStoryboardID.fxTradingTicketView
        }

        let nextViewController = self.viewControllerProvider.provideViewController(forStoryboardId: nextStoryboardId)

        if let tradingTicketViewController = nextViewController as? TradeItFxTradingTicketViewController {
            tradingTicketViewController.delegate = self
            //tradingTicketViewController.order = self.order
        }

        accountSelectionViewController.navigationController?.setViewControllers([nextViewController], animated: true)
    }

    // MARK: TradeItTradingTicketViewControllerDelegate

    internal func orderSuccessfullyPreviewed(
        onTradingTicketViewController tradingTicketViewController: TradeItTradingTicketViewController,
        withPreviewOrderResult previewOrderResult: TradeItPreviewOrderResult,
        placeOrderCallback: @escaping TradeItPlaceOrderHandlers) {
//        self.previewOrderResult = previewOrderResult

//        let nextViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.tradingPreviewView)
//
//        if let tradePreviewViewController = nextViewController as? TradeItTradePreviewViewController {
////            tradePreviewViewController.delegate = self
//            tradePreviewViewController.linkedBrokerAccount = tradingTicketViewController.order.linkedBrokerAccount
//            tradePreviewViewController.previewOrderResult = previewOrderResult
//            tradePreviewViewController.placeOrderCallback = placeOrderCallback
//        }

//        tradingTicketViewController.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
