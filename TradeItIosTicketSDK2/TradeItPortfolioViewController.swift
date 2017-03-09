import UIKit
import PromiseKit
import MBProgressHUD

class TradeItPortfolioViewController: TradeItViewController, TradeItPortfolioPositionsTableDelegate {
    var accountSummaryViewManager = TradeItPortfolioAccountSummaryViewManager()
    var positionsTableViewManager = TradeItPortfolioPositionsTableViewManager()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    var tradingUIFlow = TradeItTradingUIFlow()
    var activityView: MBProgressHUD?
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?

    @IBOutlet weak var holdingsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var positionsTable: UITableView!
    @IBOutlet weak var holdingsLabel: UILabel!
    @IBOutlet weak var accountSummaryView: TradeItAccountSummaryView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItPortfolioViewController loaded without setting linkedBrokerAccount.")
        }

        self.holdingsActivityIndicator.hidesWhenStopped = true
        self.accountSummaryViewManager.accountSummaryView = self.accountSummaryView
        self.accountSummaryViewManager.populateSummarySection(selectedAccount: linkedBrokerAccount)
        self.positionsTableViewManager.delegate = self
        self.positionsTableViewManager.positionsTable = self.positionsTable

        linkedBrokerAccount.getPositions(
            onSuccess: { positions in
                self.holdingsLabel.text = linkedBrokerAccount.getFormattedAccountName() + " Holdings"
                self.positionsTableViewManager.updatePositions(withPositions: positions)
                self.holdingsActivityIndicator.stopAnimating()
            }, onFailure: { errorResult in
                self.holdingsActivityIndicator.stopAnimating()
                // TODO: Figure out error handling
            }
        )
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

    // MARK: TradeItPortfolioPositionsTableDelegate

    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        let order = self.provideOrder(forPortFolioPosition: portfolioPosition, account: portfolioPosition?.linkedBrokerAccount, orderAction: orderAction)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
}
