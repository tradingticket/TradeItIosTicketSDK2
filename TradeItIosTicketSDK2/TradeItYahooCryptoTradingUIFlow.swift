import UIKit

class TradeItYahooCryptoTradingUIFlow:
    NSObject,
    TradeItYahooCryptoTradingTicketViewControllerDelegate,
    TradeItYahooAccountSelectionViewControllerDelegate,
    TradeItYahooTradePreviewViewControllerDelegate
{
    private let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    private var order = TradeItCryptoOrder()
    private var onViewPortfolioTappedHandler: OnViewPortfolioTappedHandler?

    internal override init() {}

    func presentTradingFlow(
        fromViewController viewController: UIViewController,
        withOrder order: TradeItCryptoOrder = TradeItCryptoOrder(),
        onViewPortfolioTappedHandler: @escaping OnViewPortfolioTappedHandler
    ) {
        self.order = order

        self.onViewPortfolioTappedHandler = onViewPortfolioTappedHandler

        let navController = TradeItYahooNavigationController()

        let initialViewController = getInitialViewController(forOrder: order)

        navController.setViewControllers([initialViewController], animated: true)

        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: Private

    private func initializeLinkedAccount(forOrder order: TradeItCryptoOrder) {
        if order.linkedBrokerAccount == nil {
            let enabledAccounts = TradeItSDK.linkedBrokerManager.getAllEnabledAccounts()
            if enabledAccounts.count == 1 {
                order.linkedBrokerAccount = enabledAccounts.first
            }
        }
    }

    private func getInitialViewController(forOrder order: TradeItCryptoOrder) -> UIViewController {
        var initialStoryboardId: TradeItStoryboardID!

        self.initializeLinkedAccount(forOrder: order)

        if (order.linkedBrokerAccount == nil) {
            initialStoryboardId = TradeItStoryboardID.yahooAccountSelectionView
        } else {
            initialStoryboardId = TradeItStoryboardID.yahooCryptoTradingTicketView
        }

        let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: initialStoryboardId)

        if let accountSelectionViewController = initialViewController as? TradeItYahooAccountSelectionViewController {
            accountSelectionViewController.delegate = self
        } else if let tradingTicketViewController = initialViewController as? TradeItYahooCryptoTradingTicketViewController {
            tradingTicketViewController.delegate = self
            tradingTicketViewController.order = order
        }

        return initialViewController
    }

    // MARK: TradeItYahooAccountSelectionViewControllerDelegate

    internal func accountSelectionViewController(
        _ accountSelectionViewController: TradeItYahooAccountSelectionViewController,
        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount
    ) {
        self.order.linkedBrokerAccount = linkedBrokerAccount

        if let tradingTicketViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooCryptoTradingTicketView) as? TradeItYahooCryptoTradingTicketViewController {
            tradingTicketViewController.delegate = self
            tradingTicketViewController.order = order
            accountSelectionViewController.navigationController?.setViewControllers([tradingTicketViewController], animated: true)
        }
    }

    // MARK: TradeItYahooTradingTicketViewControllerDelegate

    internal func orderSuccessfullyPreviewed(
        onTradingTicketViewController tradingTicketViewController: TradeItYahooCryptoTradingTicketViewController,
        withPreviewOrderResult previewOrderResult: TradeItCryptoPreviewTradeResult,
        placeOrderCallback: @escaping TradeItPlaceOrderHandlers
    ) {
        let previewViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooTradingPreviewView) as? TradeItYahooTradePreviewViewController

        if let previewViewController = previewViewController,
            let linkedBrokerAccount = self.order.linkedBrokerAccount {
            previewViewController.delegate = self
            previewViewController.linkedBrokerAccount = linkedBrokerAccount
            let factory = CryptoPreviewCellFactory(
                previewMessageDelegate: previewViewController,
                linkedBrokerAccount: linkedBrokerAccount,
                previewOrderResult: previewOrderResult
            )
            previewViewController.dataSource = PreviewTableDataSource(
                delegate: previewViewController,
                factory: factory
            )
            previewViewController.placeOrderCallback = placeOrderCallback

            tradingTicketViewController.navigationController?.pushViewController(previewViewController, animated: true)
        }
    }

    internal func invalidAccountSelected(
        onTradingTicketViewController tradingTicketViewController: TradeItYahooCryptoTradingTicketViewController,
        withOrder order: TradeItCryptoOrder
    ) {
        guard let accountSelectionViewController = self.viewControllerProvider.provideViewController(
            forStoryboardId: TradeItStoryboardID.yahooAccountSelectionView
            ) as? TradeItYahooAccountSelectionViewController else {
                print("TradeItSDK ERROR: Could not instantiate TradeItYahooAccountSelectionViewController from storyboard!")
                return
        }

        guard let navigationController = tradingTicketViewController.navigationController else {
            print("TradeItSDK ERROR: Could not get UINavigationController from TradeItYahooTradingTicketViewController!")
            return
        }

        self.order = order
        accountSelectionViewController.delegate = self
        navigationController.setViewControllers([accountSelectionViewController], animated: true)
    }

    // MARK: TradeItYahooTradingConfirmationViewControllerDelegate

    internal func viewPortfolioTapped(
        onTradePreviewViewController tradePreviewViewController: TradeItYahooTradePreviewViewController,
        linkedBrokerAccount: TradeItLinkedBrokerAccount
    ) {
        self.onViewPortfolioTappedHandler?(
            tradePreviewViewController,
            linkedBrokerAccount
        )
    }
}
