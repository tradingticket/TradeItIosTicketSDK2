protocol Order {
    var linkedBrokerAccount: { get }
}

protocol YahooTradingUIFlow:
    TradeItYahooTradingTicketViewControllerDelegate,
    TradeItYahooAccountSelectionViewControllerDelegate,
    TradeItYahooTradePreviewViewControllerDelegate {
    associatedtype TradingPreviewCellFactoryType: TradingPreviewCellFactory
    associatedtype OrderType: Order
    var onViewPortfolioTappedHandler: OnViewPortfolioTappedHandler? { get set }
    var order: Self.OrderType { get set }
    var viewControllerProvider: TradeItViewControllerProvider { get }

    func presentTradingFlow(
        fromViewController viewController: UIViewController,
        withOrder order: Self.OrderType,
        onViewPortfolioTappedHandler: @escaping OnViewPortfolioTappedHandler
    )

    // MARK: TradeItYahooAccountSelectionViewControllerDelegate

    func accountSelectionViewController(
        _ accountSelectionViewController: TradeItYahooAccountSelectionViewController,
        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount
    )

    // MARK: TradeItYahooTradingTicketViewControllerDelegate

    func orderSuccessfullyPreviewed(
        onTradingTicketViewController tradingTicketViewController: TradeItYahooCryptoTradingTicketViewController,
        withPreviewOrderResult previewOrderResult: TradeItCryptoPreviewTradeResult,
        placeOrderCallback: @escaping TradeItPlaceOrderHandlers
    )

    func invalidAccountSelected(
        onTradingTicketViewController tradingTicketViewController: TradeItYahooCryptoTradingTicketViewController,
        withOrder order: TradeItCryptoOrder
    )

    // MARK: TradeItYahooTradingConfirmationViewControllerDelegate

    func viewPortfolioTapped(
        onTradePreviewViewController tradePreviewViewController: TradeItYahooTradePreviewViewController,
        linkedBrokerAccount: TradeItLinkedBrokerAccount
    )
}

extension YahooTradingUIFlow {
    func presentTradingFlow(
        fromViewController viewController: UIViewController,
        withOrder order: Self.OrderType = Self.OrderType.init(),
        onViewPortfolioTappedHandler: @escaping OnViewPortfolioTappedHandler
    ) {
        self.order = order

        self.onViewPortfolioTappedHandler = onViewPortfolioTappedHandler

        let navController = TradeItYahooNavigationController()

        let initialViewController = getInitialViewController(forOrder: order)

        navController.setViewControllers([initialViewController], animated: true)

        viewController.present(navController, animated: true, completion: nil)
    }

    // MARK: TradeItYahooAccountSelectionViewControllerDelegate

    func accountSelectionViewController(
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

    func orderSuccessfullyPreviewed(
        onTradingTicketViewController tradingTicketViewController: TradeItYahooCryptoTradingTicketViewController,
        withPreviewOrderResult previewOrderResult: TradeItCryptoPreviewTradeResult,
        placeOrderCallback: @escaping TradeItPlaceOrderHandlers
    ) {
        let previewViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooTradingPreviewView) as? TradeItYahooTradePreviewViewController

        if let previewViewController = previewViewController,
            let linkedBrokerAccount = self.order.linkedBrokerAccount {
            previewViewController.delegate = self
            previewViewController.linkedBrokerAccount = linkedBrokerAccount

            let factory = Self.TradingPreviewCellFactoryType.init(
                previewMessageDelegate: previewViewController,
                linkedBrokerAccount: linkedBrokerAccount,
                previewOrderResult: previewOrderResult// as TradeItResult // TODO: Fix
            )
            previewViewController.dataSource = PreviewTableDataSource(
                delegate: previewViewController,
                factory: factory
            )
            previewViewController.placeOrderCallback = placeOrderCallback

            tradingTicketViewController.navigationController?.pushViewController(previewViewController, animated: true)
        }
    }

    func invalidAccountSelected(
        onTradingTicketViewController tradingTicketViewController: TradeItYahooCryptoTradingTicketViewController,
        withOrder order: Self.OrderType
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

    func viewPortfolioTapped(
        onTradePreviewViewController tradePreviewViewController: TradeItYahooTradePreviewViewController,
        linkedBrokerAccount: TradeItLinkedBrokerAccount
    ) {
        self.onViewPortfolioTappedHandler?(
            tradePreviewViewController,
            linkedBrokerAccount
        )
    }

    // MARK: Private

    private func initializeLinkedAccount(forOrder order: Self.OrderType) {
        if order.linkedBrokerAccount == nil {
            let enabledAccounts = TradeItSDK.linkedBrokerManager.getAllEnabledAccounts()
            if enabledAccounts.count == 1 {
                order.linkedBrokerAccount = enabledAccounts.first
            }
        }
    }

    private func getInitialViewController(forOrder order: Self.OrderType) -> UIViewController {
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
}
