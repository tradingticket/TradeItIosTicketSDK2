import UIKit
import PromiseKit
import MBProgressHUD

class TradeItPortfolioViewController: TradeItViewController, TradeItPortfolioAccountsTableDelegate, TradeItPortfolioErrorHandlingViewDelegate, TradeItPortfolioPositionsTableDelegate {
    
    var alertManager = TradeItAlertManager()
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager!
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    var accountSummaryViewManager = TradeItPortfolioAccountSummaryViewManager()
    var positionsTableViewManager = TradeItPortfolioPositionsTableViewManager()
    var portfolioErrorHandlingViewManager = TradeItPortfolioErrorHandlingViewManager()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    var tradingUIFlow = TradeItTradingUIFlow()

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var holdingsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var positionsTable: UITableView!
    @IBOutlet weak var holdingsLabel: UILabel!
    @IBOutlet weak var accountSummaryView: TradeItAccountSummaryView!
    
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var errorHandlingView: TradeItPortfolioErrorHandlingView!
    @IBOutlet weak var accountInfoContainerView: UIView!
    
    var selectedAccount: TradeItLinkedBrokerAccount!
    var initialAccount: TradeItLinkedBrokerAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.holdingsActivityIndicator.hidesWhenStopped = true
        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = self.accountsTable
        self.positionsTableViewManager.delegate = self
        self.positionsTableViewManager.positionsTable = self.positionsTable
        self.accountSummaryViewManager.accountSummaryView = self.accountSummaryView
        
        self.portfolioErrorHandlingViewManager.errorHandlingView = self.errorHandlingView
        self.portfolioErrorHandlingViewManager.errorHandlingView?.delegate = self

        self.portfolioErrorHandlingViewManager.accountInfoContainerView = self.accountInfoContainerView

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        self.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: { answer in
                        activityView.show(animated: true)
                        answerSecurityQuestion(answer)
                    },
                    onCancelSecurityQuestion: cancelSecurityQuestion)
            },
            onFinished: {
                activityView.label.text = "Refreshing Accounts"

                self.linkedBrokerManager.refreshAccountBalances(
                    onFinished: {
                        self.updatePortfolioScreen()
                        activityView.hide(animated: true)
                    }
                )
            }
        )
    }
    
    // MARK: private methods

    private func updatePortfolioScreen() {
        let accounts = self.linkedBrokerManager.getAllEnabledAccounts()
        let linkedBrokersInError = self.linkedBrokerManager.getAllLinkedBrokersInError()
        self.accountsTableViewManager.updateAccounts(withAccounts: accounts, withLinkedBrokersInError: linkedBrokersInError, withSelectedAccount: self.initialAccount)
        self.updateTotalValueLabel(withAccounts: accounts)
        if (accounts.count == 0) {
            self.positionsTableViewManager.updatePositions(withPositions: [])
        }
    }
    
    private func updateTotalValueLabel(withAccounts accounts: [TradeItLinkedBrokerAccount]) {
        var totalAccountsValue: Float = 0
        for account in accounts {
            if let balance = account.balance, let totalValue = balance.totalValue {
                totalAccountsValue += totalValue.floatValue
            } else if let fxBalance = account.fxBalance, let totalValueUSD = fxBalance.totalValueUSD {
                totalAccountsValue += totalValueUSD.floatValue
            }
        }
        // TODO: CurrencyCode here should not be nil. Currency could be set per position or per account, so an aggregate makes no sense unless we convert it all to a single currency.
        self.totalValueLabel.text = NumberFormatter.formatCurrency(NSNumber(value: totalAccountsValue), currencyCode: nil)
    }
    
    private func provideOrder(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?,
                                                   account: TradeItLinkedBrokerAccount?,
                                                   orderAction: TradeItOrderAction?) -> TradeItOrder {
            let order = TradeItOrder()
            order.linkedBrokerAccount = account
            if let portfolioPosition = portfolioPosition {
                order.symbol = TradeItPortfolioPositionPresenterFactory.forTradeItPortfolioPosition(portfolioPosition).getFormattedSymbol()
            }
            order.action = orderAction ?? TradeItOrderActionPresenter.DEFAULT
            return order
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
        let order = provideOrder(forPortFolioPosition: nil, account: self.selectedAccount, orderAction: nil)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    // MARK: - TradeItPortfolioAccountsTableDelegate methods
    
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount) {
        self.portfolioErrorHandlingViewManager.showAccountInfoContainerView()
        self.holdingsActivityIndicator.startAnimating()
        self.accountSummaryViewManager.populateSummarySection(selectedAccount: selectedAccount)
        selectedAccount.getPositions(
            onSuccess: { positions in
                self.holdingsLabel.text = selectedAccount.getFormattedAccountName() + " Holdings"
                self.selectedAccount = selectedAccount
                self.positionsTableViewManager.updatePositions(withPositions: positions)
                self.holdingsActivityIndicator.stopAnimating()
            }, onFailure: { errorResult in
                print(errorResult)
            }
        )
    }
    
    func linkedBrokerInErrorWasSelected(selectedBrokerInError: TradeItLinkedBroker) {
        self.portfolioErrorHandlingViewManager.showErrorHandlingView(withLinkedBrokerInError: selectedBrokerInError)
    }
    
    // MARK: TradeItPortfolioPositionsTableDelegate
    
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        let order = self.provideOrder(forPortFolioPosition: portfolioPosition, account: portfolioPosition?.linkedBrokerAccount, orderAction: orderAction)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    // MARK: TradeItPortfolioErrorHandlingViewDelegate methods
    
    func relinkAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: linkedBroker,
            onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                presentedNavController.dismiss(animated: true, completion: nil)
                let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
                activityView.label.text = "Refreshing Accounts"

                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        activityView.hide(animated: true)
                        self.updatePortfolioScreen()
                })
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                //Nothing to do
            }
        )
    }
    
    func reloadAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        linkedBroker.authenticate(
            onSuccess: {
                activityView.label.text = "Refreshing Accounts"
                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        activityView.hide(animated: true)
                        self.updatePortfolioScreen()
                    }
                )
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { error in
                activityView.hide(animated: true)
                self.alertManager.showRelinkError(error, withLinkedBroker: linkedBroker, onViewController: self, onFinished: {})
            }
        )
    }
}
