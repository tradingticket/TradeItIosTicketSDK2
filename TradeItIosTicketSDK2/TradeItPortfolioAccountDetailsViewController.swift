import UIKit
import MBProgressHUD
import PromiseKit

class TradeItPortfolioAccountDetailsViewController: TradeItViewController, TradeItPortfolioAccountDetailsTableDelegate {
    var tableViewManager: TradeItPortfolioAccountDetailsTableViewManager!
    var tradingUIFlow = TradeItTradingUIFlow()
    let viewControllerProvider = TradeItViewControllerProvider()
    var alertManager = TradeItAlertManager()
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    private var brokerSupportedService: [(supportedService: SupportedService, handler: ((_ alert: UIAlertAction) -> ()))] = []

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var adContainer: UIView!
    @IBOutlet weak var activityButton: UIBarButtonItem!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            alertMissingRequiredParameter()
            return
        }

        self.tableViewManager = TradeItPortfolioAccountDetailsTableViewManager(account: linkedBrokerAccount)

        self.tableViewManager.delegate = self
        self.tableViewManager.table = self.table

        self.fetchBrokerSupportedServices()
        self.tableViewManager.initiateRefresh()

        TradeItSDK.adService.populate(
            adContainer: self.adContainer,
            rootViewController: self,
            pageType: .portfolio,
            position: .bottom,
            broker: linkedBrokerAccount.linkedBroker?.brokerName,
            symbol: nil,
            instrumentType: nil,
            trackPageViewAsPageType: true
        )
    }
    
    @IBAction func activityTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        self.brokerSupportedService.forEach { (supportedService, handler) in
            let action = UIAlertAction(title: supportedService.getActionTitle(), style: .default, handler: handler)
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad,
            let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    func refreshRequested(onRefreshComplete: @escaping () -> Void) {
        guard let linkedBrokerAccount = self.linkedBrokerAccount, let linkedBroker = linkedBrokerAccount.linkedBroker else {
            alertMissingRequiredParameter()
            return
        }

        let accountOverviewPromise = Promise<Void> { seal in
            linkedBrokerAccount.getAccountOverview(
                cacheResult: true,
                onSuccess: { _ in
                    self.tableViewManager.updateAccount(withAccount: linkedBrokerAccount)
                    seal.fulfill(())
                },
                onFailure: { error in
                    self.tableViewManager.updateAccount(withAccount: nil)
                    seal.reject(error)
                }
            )
        }

        let positionsAndQuotesPromise = self.positionsPromise(linkedBrokerAccount: linkedBrokerAccount).then { portfolioPositions in
            return self.quotesPromise(portfolioPositions: portfolioPositions)
        }

        linkedBroker.authenticatePromise(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            }
        ).then { _ in
            return when(fulfilled: accountOverviewPromise, positionsAndQuotesPromise)
        }.done { results in
            return self.tableViewManager.updatePositions(withPositions: results.1)
        }.ensure(onRefreshComplete)
        .catch { error in
            if let tradeItError = linkedBroker.error {
                self.alertManager.showAlertWithAction(error: tradeItError, withLinkedBroker: linkedBroker, onViewController: self)
            }
        }
    }

    // MARK: Private

    private func positionsPromise(linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Promise<[TradeItPortfolioPosition]> {
        return Promise<[TradeItPortfolioPosition]> { seal in
            linkedBrokerAccount.getPositions(
                onSuccess: seal.fulfill,
                onFailure: { error in
                    self.tableViewManager.updatePositions(withPositions: nil)
                    seal.reject(error)
                }
            )
        }
    }
  
    private func quotesPromise(portfolioPositions: [TradeItPortfolioPosition]) -> Promise<[TradeItPortfolioPosition]> {
        let symbols = portfolioPositions
            .filter { $0.position?.lastPrice == nil }
            .compactMap { $0.position?.symbol }

        return Promise<[TradeItPortfolioPosition]> { seal in
            guard !symbols.isEmpty,
                let getQuotes = TradeItSDK.marketDataService.getQuotes
                else { return seal.fulfill(portfolioPositions) }

            getQuotes(
                symbols,
                { quotes in
                    let portfolioPositionsWithQuotes: [TradeItPortfolioPosition] = portfolioPositions.map { portfolioPosition in
                        if let quote = quotes.first(where: { $0.symbol == portfolioPosition.position?.symbol }) {
                            portfolioPosition.quote = quote
                            portfolioPosition.position?.lastPrice = quote.lastPrice
                        }
                        return portfolioPosition
                    }

                    seal.fulfill(portfolioPositionsWithQuotes)
                },
                seal.reject
            )
        }
    }

    private func fetchBrokerSupportedServices() {
        guard let brokerShortName = self.linkedBrokerAccount?.brokerName else {
            return
        }
        TradeItSDK.linkedBrokerManager.getBroker(
            shortName: brokerShortName,
            onSuccess: { broker in
                self.brokerSupportedService = [
                    (supportedService: SupportedService.orders, handler: self.orderActionWasTapped),
                    (supportedService: SupportedService.transactions, handler: self.transactionActionWasTapped),
                    (supportedService: SupportedService.trading, handler: self.tradeActionWasTapped)
                ].filter {$0.supportedService.supportsService(broker: broker) }
                self.activityButton.isEnabled = self.brokerSupportedService.count > 0
            },
            onFailure: {_ in}
        )
    }

    private func tradeActionWasTapped(alert: UIAlertAction) {
        let order = provideOrder(forPortfolioPosition: nil, account: self.linkedBrokerAccount, orderAction: nil)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    private func transactionActionWasTapped(alert: UIAlertAction) {
        guard let transactionsViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .transactionsView) as? TradeItTransactionsViewController else {
            return
        }
        transactionsViewController.linkedBrokerAccount = self.linkedBrokerAccount
        self.navigationController?.pushViewController(transactionsViewController, animated: true)
    }
    
    private func orderActionWasTapped(alert: UIAlertAction) {
        guard let ordersViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .ordersView) as? TradeItOrdersViewController else {
            return
        }
        ordersViewController.linkedBrokerAccount = self.linkedBrokerAccount
        ordersViewController.enableThemeOnLoad = false
        ordersViewController.view.backgroundColor = UIColor.tradeItlightGreyHeaderBackgroundColor
        self.navigationController?.pushViewController(ordersViewController, animated: true)
    }
    
    private func provideOrder(forPortfolioPosition portfolioPosition: TradeItPortfolioPosition?,
                                                   account: TradeItLinkedBrokerAccount?,
                                                   orderAction: TradeItOrderAction?) -> TradeItOrder {
        let order = TradeItOrder()
        order.linkedBrokerAccount = account
        if let portfolioPosition = portfolioPosition {
            order.symbol = TradeItPortfolioEquityPositionPresenter(portfolioPosition).getFormattedSymbol()
        }
        order.action = orderAction ?? TradeItOrderActionPresenter.DEFAULT
        return order
    }

    private func alertMissingRequiredParameter() {
        let systemMessage = "TradeItPortfolioAccountDetailsViewController.swift loaded without setting linkedBrokerAccount."
        print("TradeItIosTicketSDK ERROR: \(systemMessage)")
        self.alertManager.showError(
            TradeItErrorResult.error(withSystemMessage: systemMessage),
            onViewController: self,
            onFinished: {
                self.closeButtonWasTapped()
            }
        )
    }

    // MARK: TradeItPortfolioAccountDetailsTableDelegate

    func tradeButtonWasTapped(forPortfolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        let order = self.provideOrder(forPortfolioPosition: portfolioPosition, account: portfolioPosition?.linkedBrokerAccount, orderAction: orderAction)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
}

fileprivate enum SupportedService: String {
    case orders
    case transactions
    case trading

    func getActionTitle() -> String {
        switch self {
        case .orders: return "Orders"
        case .trading: return "Trade"
        case .transactions: return "Transactions"
        }
    }

    func supportsService(broker: TradeItBroker) -> Bool {
        switch self {
        case .orders: return broker.supportsOrderStatus()
        case .trading: return broker.supportsTrading()
        case .transactions: return broker.supportsTransactionsHistory()
        }
    }
}
