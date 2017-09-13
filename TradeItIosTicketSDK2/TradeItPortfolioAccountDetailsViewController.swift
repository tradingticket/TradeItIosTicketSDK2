import UIKit
import MBProgressHUD
import PromiseKit

class TradeItPortfolioAccountDetailsViewController: TradeItViewController, TradeItPortfolioAccountDetailsTableDelegate {
    var tableViewManager: TradeItPortfolioAccountDetailsTableViewManager!
    var tradingUIFlow = TradeItTradingUIFlow()
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

        TradeItSDK.adService.populate?(
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

    @IBAction func tradeTapped(_ sender: Any) {
        let order = provideOrder(forPortFolioPosition: nil, account: self.linkedBrokerAccount, orderAction: nil)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }

    func refreshRequested(onRefreshComplete: @escaping () -> Void) {
        guard let linkedBrokerAccount = self.linkedBrokerAccount, let linkedBroker = linkedBrokerAccount.linkedBroker else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItPortfolioViewController loaded without setting linkedBrokerAccount.")
        }

        let authenticatePromise = Promise { fulfill, reject in
            linkedBroker.authenticateIfNeeded(
                onSuccess: fulfill,
                onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                    self.alertManager.promptUserToAnswerSecurityQuestion(
                        securityQuestion,
                        onViewController: self,
                        onAnswerSecurityQuestion: answerSecurityQuestion,
                        onCancelSecurityQuestion: cancelSecurityQuestion
                    )
                },
                onFailure: reject
            )
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

        let positionsPromise = Promise<[TradeItPortfolioPosition]> { fulfill, reject in
            linkedBrokerAccount.getPositions(
                onSuccess: { positions in
                    //self.tableViewManager.updatePositions(withPositions: positions)
                    fulfill(positions)
                },
                onFailure: { error in
                    self.tableViewManager.updatePositions(withPositions: nil)
                    reject(error)
                }
            )
        }

        authenticatePromise.then { _ in
            return when(fulfilled: accountOverviewPromise, positionsPromise)
        }.then { _, positions in
            return self.updateQuotes(positions: positions)
        }.then { positions in
            self.tableViewManager.updatePositions(withPositions: positions)
        }.always {
            onRefreshComplete()
        }.catch { error in
            print(error)
        }
    }

    // MARK: Private

    private func updateQuotes(positions: [TradeItPortfolioPosition]) -> Promise<[TradeItPortfolioPosition]> {
        let symbols = positions
            .filter { $0.position?.lastPrice == nil }
            .map { $0.position?.symbol }
            .flatMap { $0 }
        return Promise<[TradeItPortfolioPosition]> { fulfill, reject in
            guard let getQuotes = TradeItSDK.marketDataService.getQuotes else { return fulfill(positions) }
            getQuotes(
                symbols,
                { quotes in
                    let positionsWithQuotes: [TradeItPortfolioPosition] = positions.map { position in
                        if let quote = quotes.first(where: { $0.symbol == position.position?.symbol }) {
                            position.quote = quote
                            position.position?.lastPrice = quote.lastPrice
                        }
                        return position
                    }

                    fulfill(positionsWithQuotes)
                },
                reject
            )
        }
    }

    private func provideOrder(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?,
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

    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        let order = self.provideOrder(forPortFolioPosition: portfolioPosition, account: portfolioPosition?.linkedBrokerAccount, orderAction: orderAction)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
}
