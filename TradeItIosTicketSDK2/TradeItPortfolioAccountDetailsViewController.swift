import UIKit
import MBProgressHUD

class TradeItPortfolioAccountDetailsViewController: TradeItViewController, TradeItPortfolioAccountDetailsTableDelegate {
    var tableViewManager = TradeItPortfolioAccountDetailsTableViewManager()
    var tradingUIFlow = TradeItTradingUIFlow()
    var alertManager = TradeItAlertManager()
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?

    @IBOutlet weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItPortfolioViewController loaded without setting linkedBrokerAccount.")
        }

        self.navigationItem.title = linkedBrokerAccount.linkedBroker?.brokerName

        self.tableViewManager.delegate = self
        self.tableViewManager.table = self.table
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableViewManager.initiateRefresh()
    }

    func refreshRequested(onRefreshComplete: @escaping () -> Void) {
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItPortfolioViewController loaded without setting linkedBrokerAccount.")
        }

        linkedBrokerAccount.linkedBroker?.authenticateIfNeeded(onSuccess: {
            linkedBrokerAccount.getAccountOverview(onSuccess: { _ in
                self.tableViewManager.updateAccount(withAccount: linkedBrokerAccount)
                onRefreshComplete()
            }, onFailure: { errorResult in
                // TODO: Figure out error handling
                print(errorResult)
                onRefreshComplete()
            })

            linkedBrokerAccount.getPositions(
                onSuccess: { positions in
                    self.tableViewManager.updatePositions(withPositions: positions)
                    onRefreshComplete()
                }, onFailure: { errorResult in
                    // TODO: Figure out error handling
                    print(errorResult)
                    onRefreshComplete()
                }
            )
        }, onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
            self.alertManager.promptUserToAnswerSecurityQuestion(
                securityQuestion,
                onViewController: self,
                onAnswerSecurityQuestion: answerSecurityQuestion,
                onCancelSecurityQuestion: cancelSecurityQuestion
            )
        }, onFailure: { errorResult in
            // TODO: Figure out error handling
            print(errorResult)
            onRefreshComplete()
        })
    }

    // MARK: Private

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

    // MARK: IBActions

    // TODO: Replace with Accounts button up top
    //    @IBAction func editAccountsButtonTapped(_ sender: UIButton) {
    //        TradeItSDK.launcher.launchAccountManagement(fromViewController: self)
    //    }

    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.parent?.dismiss(animated: true, completion: nil)
    }

    // TODO: Move to detail view
    //    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
    //        let order = provideOrder(forPortFolioPosition: nil, account: self.selectedAccount, orderAction: nil)
    //        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    //    }

    // MARK: TradeItPortfolioAccountDetailsTableDelegate

    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        let order = self.provideOrder(forPortFolioPosition: portfolioPosition, account: portfolioPosition?.linkedBrokerAccount, orderAction: orderAction)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
}
