import UIKit
import PromiseKit

class TradeItPortfolioViewController: UIViewController, TradeItPortfolioAccountsTableDelegate, TradeItPortfolioErrorHandlingViewDelegate, TradeItPortfolioPositionsTableDelegate {
    
    var alertManager = TradeItAlertManager()
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var ezLoadingActivityManager = EZLoadingActivityManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    var accountSummaryViewManager = TradeItPortfolioAccountSummaryViewManager()
    var positionsTableViewManager = TradeItPortfolioPositionsTableViewManager()
    var portfolioErrorHandlingViewManager = TradeItPortfolioErrorHandlingViewManager()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
    var tradingUIFlow = TradeItTradingUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var holdingsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var positionsTable: UITableView!
    @IBOutlet weak var holdingsLabel: UILabel!
    @IBOutlet weak var accountSummaryView: TradeItAccountSummaryView!
    
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var errorHandlingView: TradeItPortfolioErrorHandlingView!
    @IBOutlet weak var accountInfoContainerView: UIView!
    
    var selectedAccount: TradeItLinkedBrokerAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = self.accountsTable
        self.positionsTableViewManager.delegate = self
        self.positionsTableViewManager.positionsTable = self.positionsTable
        self.accountSummaryViewManager.accountSummaryView = self.accountSummaryView
        
        self.portfolioErrorHandlingViewManager.errorHandlingView = self.errorHandlingView
        self.portfolioErrorHandlingViewManager.errorHandlingView?.delegate = self

        self.portfolioErrorHandlingViewManager.accountInfoContainerView = self.accountInfoContainerView
        
        self.ezLoadingActivityManager.show(text: "Authenticating", disableUI: true)

        self.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: (String) -> Void, cancelSecurityQuestion: () -> Void) in
                self.ezLoadingActivityManager.hide()
                self.alertManager.show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: { (answer: String) in
                        self.ezLoadingActivityManager.show(text: "Authenticating", disableUI: true)
                        answerSecurityQuestion(answer)
                    },
                    onCancelSecurityQuestion: cancelSecurityQuestion)
            },
            onFinished: {
                self.ezLoadingActivityManager.updateText(text: "Refreshing Accounts")

                self.linkedBrokerManager.refreshAccountBalances(
                    onFinished: {
                        self.updatePortfolioScreen()
                        self.ezLoadingActivityManager.hide()
                    }
                )
            }
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updatePortfolioScreen()
    }
    
    // MARK: private methods

    private func updatePortfolioScreen() {
        let accounts = self.linkedBrokerManager.getAllEnabledAccounts()
        let linkedBrokersInError = self.linkedBrokerManager.getAllLinkedBrokersInError()
        self.accountsTableViewManager.updateAccounts(withAccounts: accounts, withLinkedBrokersInError: linkedBrokersInError)
        self.updateTotalValueLabel(withAccounts: accounts)
        if (accounts.count == 0) {
            self.positionsTableViewManager.updatePositions(withPositions: [])
        }
    }
    
    private func updateTotalValueLabel(withAccounts accounts: [TradeItLinkedBrokerAccount]) {
        var totalAccountsValue: Float = 0
        for account in accounts {
            if let balance = account.balance, let totalValue = balance.totalValue {
                totalAccountsValue += totalValue  as Float
            } else if let fxBalance = account.fxBalance, let totalValueUSD = fxBalance.totalValueUSD {
                totalAccountsValue += totalValueUSD as Float
            }
        }
        self.totalValueLabel.text = NumberFormatter.formatCurrency(totalAccountsValue)
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tradeButtonWasTapped(sender: AnyObject) {
        let order = TradeItOrder()
        order.linkedBrokerAccount = self.selectedAccount
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    // MARK: - TradeItPortfolioAccountsTableDelegate methods
    
    func linkedBrokerAccountWasSelected(selectedAccount selectedAccount: TradeItLinkedBrokerAccount) {
        self.portfolioErrorHandlingViewManager.showAccountInfoContainerView()
        self.holdingsActivityIndicator.startAnimating()
        self.accountSummaryViewManager.populateSummarySection(selectedAccount)
        selectedAccount.getPositions(
            onSuccess: {
                self.holdingsLabel.text = selectedAccount.getFormattedAccountName() + " Holdings"
                self.selectedAccount = selectedAccount
                self.positionsTableViewManager.updatePositions(withPositions: selectedAccount.positions)
                self.holdingsActivityIndicator.stopAnimating()
            }, onFailure: { errorResult in
                print(errorResult)
            }
        )
    }
    
    func linkedBrokerInErrorWasSelected(selectedBrokerInError selectedBrokerInError: TradeItLinkedBroker) {
        self.portfolioErrorHandlingViewManager.showErrorHandlingView(withLinkedBrokerInError: selectedBrokerInError)
    }
    
    // MARK: TradeItPortfolioPositionsTableDelegate
    
    func buyButtonWasTappedWith(order order: TradeItOrder) {
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    func sellButtonWasTappedWith(order order: TradeItOrder) {
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    // MARK: TradeItPortfolioErrorHandlingViewDelegate methods
    
    func relinkAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: linkedBroker,
            onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                self.ezLoadingActivityManager.show(text: "Refreshing Accounts", disableUI: true)
                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.ezLoadingActivityManager.hide()
                        self.updatePortfolioScreen()
                })
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                //Nothing to do
            }
        )
    }
    
    func reloadAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.ezLoadingActivityManager.show(text: "Authenticating", disableUI: true)
        linkedBroker.authenticate(
            onSuccess: { () -> Void in
                self.ezLoadingActivityManager.updateText(text: "Refreshing Accounts")
                    linkedBroker.refreshAccountBalances(
                        onFinished: {
                            self.ezLoadingActivityManager.hide()
                            self.updatePortfolioScreen()
                    })
            },
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: (String) -> Void, cancelSecurityQuestion: () -> Void) -> Void in
                self.ezLoadingActivityManager.hide()
                self.alertManager.show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                self.ezLoadingActivityManager.hide()
                self.alertManager.show(tradeItErrorResult: tradeItErrorResult, onViewController: self, withLinkedBroker: linkedBroker, onFinished: {})
            }
        )
    }
}
