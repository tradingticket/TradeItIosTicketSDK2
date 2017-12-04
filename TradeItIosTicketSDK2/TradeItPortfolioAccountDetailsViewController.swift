import UIKit
import MBProgressHUD
import PromiseKit

class TradeItPortfolioAccountDetailsViewController: TradeItViewController, TradeItPortfolioAccountDetailsTableDelegate {
    var tableViewManager: TradeItPortfolioAccountDetailsTableViewManager!
    var tradingUIFlow = TradeItTradingUIFlow()
    let viewControllerProvider = TradeItViewControllerProvider()
    var alertManager = TradeItAlertManager()
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var adContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItPortfolioViewController loaded without setting linkedBrokerAccount.")
        }

        self.tableViewManager = TradeItPortfolioAccountDetailsTableViewManager(account: linkedBrokerAccount)
        self.navigationItem.title = linkedBrokerAccount.linkedBroker?.brokerLongName

        self.tableViewManager.delegate = self
        self.tableViewManager.table = self.table

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
        
        let ordersAction = UIAlertAction(title: "Orders", style: .default, handler: orderActionWasTapped)
        let transactionsAction = UIAlertAction(title: "Transactions", style: .default, handler: transactionActionWasTapped)
        let tradeAction = UIAlertAction(title: "Trade", style: .default, handler: tradeActionWasTapped)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(ordersAction)
        alertController.addAction(transactionsAction)
        alertController.addAction(tradeAction)
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad,
            let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    func refreshRequested(onRefreshComplete: @escaping () -> Void) {
        guard let linkedBrokerAccount = self.linkedBrokerAccount, let linkedBroker = linkedBrokerAccount.linkedBroker else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItPortfolioViewController loaded without setting linkedBrokerAccount.")
        }

        let accountOverviewPromise = Promise<Void> { fulfill, reject in
            linkedBrokerAccount.getAccountOverview(
                cacheResult: true,
                onSuccess: { _ in
                    self.tableViewManager.updateAccount(withAccount: linkedBrokerAccount)
                    fulfill()
                },
                onFailure: { error in
                    self.tableViewManager.updateAccount(withAccount: nil)
                    reject(error)
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
        }.then { _, positions in
            self.tableViewManager.updatePositions(withPositions: positions)
        }.always {
            onRefreshComplete()
        }.catch { error in
            if let tradeItError = linkedBroker.error {
                self.alertManager.showAlertWithAction(error: tradeItError, withLinkedBroker: linkedBroker, onViewController: self)
            }
        }
    }

    // MARK: Private

    private func positionsPromise(linkedBrokerAccount: TradeItLinkedBrokerAccount) -> Promise<[TradeItPortfolioPosition]> {
        return Promise<[TradeItPortfolioPosition]> { fulfill, reject in
            linkedBrokerAccount.getPositions(
                onSuccess: { positions in
                    fulfill(positions)
                },
                onFailure: { error in
                    self.tableViewManager.updatePositions(withPositions: nil)
                    reject(error)
                }
            )
        }
    }
  
    private func quotesPromise(portfolioPositions: [TradeItPortfolioPosition]) -> Promise<[TradeItPortfolioPosition]> {
        let symbols = portfolioPositions
            .filter { $0.position?.lastPrice == nil }
            .flatMap { $0.position?.symbol }

        return Promise<[TradeItPortfolioPosition]> { fulfill, reject in
            guard !symbols.isEmpty,
                let getQuotes = TradeItSDK.marketDataService.getQuotes
                else { return fulfill(portfolioPositions) }

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

                    fulfill(portfolioPositionsWithQuotes)
                },
                reject
            )
        }
    }

    // MARK: Private

    private func tradeActionWasTapped(alert: UIAlertAction!) {
        let order = provideOrder(forPortfolioPosition: nil, account: self.linkedBrokerAccount, orderAction: nil)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    private func transactionActionWasTapped(alert: UIAlertAction!) {
        guard let transactionsViewController = self.viewControllerProvider.provideViewController(forStoryboardId: .transactionsView) as? TradeItTransactionsViewController else {
            return
        }
        transactionsViewController.linkedBrokerAccount = self.linkedBrokerAccount
        self.navigationController?.pushViewController(transactionsViewController, animated: true)
    }
    
    private func orderActionWasTapped(alert: UIAlertAction!) {
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

    // MARK: TradeItPortfolioAccountDetailsTableDelegate

    func tradeButtonWasTapped(forPortfolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        let order = self.provideOrder(forPortfolioPosition: portfolioPosition, account: portfolioPosition?.linkedBrokerAccount, orderAction: orderAction)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
}
