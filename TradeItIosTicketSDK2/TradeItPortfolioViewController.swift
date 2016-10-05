import UIKit
import PromiseKit
import TradeItIosEmsApi

class TradeItPortfolioViewController: UIViewController, TradeItPortfolioAccountsTableDelegate, TradeItPortfolioErrorHandlingViewDelegate {
    
    var tradeItAlert = TradeItAlert()
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var ezLoadingActivityManager = EZLoadingActivityManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    var accountSummaryViewManager = TradeItPortfolioAccountSummaryViewManager()
    var positionsTableViewManager = TradeItPortfolioPositionsTableViewManager()
    var portfolioViewErrorHandlerManager = TradeItPortfolioErrorHandlerManager()
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var holdingsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var positionsTable: UITableView!
    @IBOutlet weak var holdingsLabel: UILabel!
    @IBOutlet weak var accountSummaryView: TradeItAccountSummaryView!
    
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var errorHandlingView: TradeItPortfolioErrorHandlingView!
    @IBOutlet weak var otherTablesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = self.accountsTable
        self.positionsTableViewManager.positionsTable = self.positionsTable
        self.accountSummaryViewManager.accountSummaryView = self.accountSummaryView
        
        self.portfolioViewErrorHandlerManager.errorHandlingView = self.errorHandlingView
        self.portfolioViewErrorHandlerManager.errorHandlingView?.delegate = self

        self.portfolioViewErrorHandlerManager.otherTablesView = self.otherTablesView
        
        self.ezLoadingActivityManager.show(text: "Authenticating", disableUI: true)

        self.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: (String) -> Void) in
                self.tradeItAlert.show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion
                )
            },
            onFinished: {
                self.ezLoadingActivityManager.updateText(text: "Refreshing Accounts")

                self.linkedBrokerManager.refreshAccountBalances(
                    onFinished:  {
                        self.updatePortfolioView()
                        self.ezLoadingActivityManager.hide()
                    }
                )
            }
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updatePortfolioView()
    }
    
    //MARK: private methods

    private func updatePortfolioView() {
        let accounts = self.linkedBrokerManager.getAllEnabledAccounts()
        let linkedBrokersInError = self.linkedBrokerManager.getAllLinkedBrokersInError()
        self.accountsTableViewManager.updateAccounts(withAccounts: accounts, withLinkedBrokersInError: linkedBrokersInError)
        self.updateAllAccountsValue(withAccounts: accounts)
        if (accounts.count == 0) {
            self.positionsTableViewManager.updatePositions(withPositions: [])
        }
    }
    
    private func updateAllAccountsValue(withAccounts accounts: [TradeItLinkedBrokerAccount]) {
        var totalValue: Float = 0
        for account in accounts {
            if let balance = account.balance {
                totalValue += balance.totalValue as Float
            } else if let fxBalance = account.fxBalance {
                totalValue += fxBalance.totalValueUSD as Float
            }
        }
        self.totalValueLabel.text = NumberFormatter.formatCurrency(totalValue)
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - TradeItPortfolioAccountsTableDelegate methods
    
    func linkedBrokerAccountWasSelected(selectedAccount selectedAccount: TradeItLinkedBrokerAccount) {
        self.portfolioViewErrorHandlerManager.showOtherTablesView()
        self.holdingsActivityIndicator.startAnimating()
        self.accountSummaryViewManager.populateSummarySection(selectedAccount)
        selectedAccount.getPositions(
            onFinished: {
                self.holdingsActivityIndicator.stopAnimating()
                self.holdingsLabel.text = selectedAccount.getFormattedAccountName() + " Holdings"
                self.positionsTableViewManager.updatePositions(withPositions: selectedAccount.positions)
                self.holdingsActivityIndicator.stopAnimating()
            }
        )
    }
    
    func linkedBrokerInErrorWasSelected(selectedBrokerInError selectedBrokerInError: TradeItLinkedBroker) {
        self.portfolioViewErrorHandlerManager.showErrorHandlingView(withLinkedBrokerInError: selectedBrokerInError)
    }
    
    // MARK: TradeItPortfolioErrorHandlingViewDelegate methods
    
    func relinkAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: linkedBroker,
            onLinked: { (presentedNavController: UINavigationController) -> Void in
                presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                self.ezLoadingActivityManager.show(text: "Refreshing Accounts", disableUI: true)
                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.ezLoadingActivityManager.hide()
                        self.updatePortfolioView()
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
                            self.updatePortfolioView()
                    })
            },
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: (String) -> Void) -> Void in
                self.ezLoadingActivityManager.hide()
                self.tradeItAlert.show(
                    securityQuestion: securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion
                )
            },
            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                self.ezLoadingActivityManager.hide()
                linkedBroker.isAuthenticated = false
                linkedBroker.error = tradeItErrorResult
                self.updatePortfolioView()
            }
        )
    }
    
}
