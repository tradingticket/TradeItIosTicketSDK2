import UIKit

class TradeItFxTradingUIFlow: TradeItAccountSelectionViewControllerDelegate, TradeItFxTradingTicketViewControllerDelegate, TradeItTradingConfirmationViewControllerDelegate {
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItFxOrder()
    var placeOrderResult: TradeItFxPlaceOrderResult?

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

        let nextStoryboardId = TradeItStoryboardID.fxTradingTicketView
        let nextViewController = self.viewControllerProvider.provideViewController(forStoryboardId: nextStoryboardId)

        if let tradingTicketViewController = nextViewController as? TradeItFxTradingTicketViewController {
            tradingTicketViewController.delegate = self
            tradingTicketViewController.order = self.order
        }

        accountSelectionViewController.navigationController?.setViewControllers([nextViewController], animated: true)
    }

    // MARK: TradeItFxTradingTicketViewControllerDelegate

    internal func orderSuccessfullyPlaced(
        onFxTradingTicketViewController fxTradingTicketViewController: TradeItFxTradingTicketViewController,
        withPlaceOrderResult placeOrderResult: TradeItFxPlaceOrderResult
    ) {
        let nextViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.tradingConfirmationView)

        if let tradingConfirmationViewController = nextViewController as? TradeItTradingConfirmationViewController {
            tradingConfirmationViewController.delegate = self
            let orderLeg = placeOrderResult.orderInfoOutput?.orderLegs.first as? TradeItFxOrderLegResult? ?? TradeItFxOrderLegResult()
            tradingConfirmationViewController.orderNumber = orderLeg?.orderNumber
            tradingConfirmationViewController.timestamp = placeOrderResult.timestamp
            tradingConfirmationViewController.confirmationMessage = placeOrderResult.confirmationMessage

            // Analytics tracking only
            tradingConfirmationViewController.broker = order.linkedBrokerAccount?.linkedBroker?.brokerName
            tradingConfirmationViewController.symbol = order.symbol
            tradingConfirmationViewController.instrument = TradeItTradeInstrumentType.fx.rawValue
        }

        fxTradingTicketViewController.navigationController?.setViewControllers([nextViewController], animated: true)
    }

    // MARK: TradeItTradingConfirmationViewControllerDelegate

    internal func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItTradingConfirmationViewController) {
        if let navigationController = tradeItTradingConfirmationViewController.navigationController {
            self.pushTradingFlow(onNavigationController: navigationController, asRootViewController: true)
        } else if let presentingViewController = tradeItTradingConfirmationViewController.presentingViewController {
            self.presentTradingFlow(fromViewController: presentingViewController)
        }
    }
}
