import UIKit
import PromiseKit
import TradeItIosEmsApi

class TradeItPortfolioViewController: UIViewController, TradeItPortfolioAccountsTableDelegate {
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var ezLoadingActivityManager = EZLoadingActivityManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    var fxSummaryViewManager = TradeItPortfolioFxSummaryViewManager()
    var positionsTableViewManager = TradeItPortfolioPositionsTableViewManager()
    
    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var fxSummaryView: TradeItFxSummaryView!
    @IBOutlet weak var holdingsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var positionsTable: UITableView!
    @IBOutlet weak var holdingsLabel: UILabel!
    
    @IBOutlet weak var totalValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = accountsTable
        self.positionsTableViewManager.positionsTable = positionsTable
        self.fxSummaryViewManager.fxSummaryView = fxSummaryView
        
        self.ezLoadingActivityManager.show(text: "Authenticating", disableUI: true)

        self.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { (TradeItSecurityQuestionResult) -> String in
                // TODO: GET
                return "MY SPECIAL SECURITY ANSWER"
            },
            onFinished: {
                self.ezLoadingActivityManager.updateText(text: "Refreshing Accounts")

                self.linkedBrokerManager.refreshAccountBalances(
                    onFinished:  {
                        let accounts = self.linkedBrokerManager.getAllEnabledAccounts()
                        self.accountsTableViewManager.updateAccounts(withAccounts: accounts)
                        self.updateAllAccountsValue(withAccounts: accounts)
                        self.ezLoadingActivityManager.hide()
                    }
                )
            }
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        let accounts = self.linkedBrokerManager.getAllEnabledAccounts()
        self.accountsTableViewManager.updateAccounts(withAccounts: accounts)
        self.updateAllAccountsValue(withAccounts: accounts)
        if (accounts.count == 0) {
            self.positionsTableViewManager.updatePositions(withPositions: [])
        }
    }
    
    //MARK: private methods

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
        self.parentViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - TradeItPortfolioAccountsTableDelegate
    
    func linkedBrokerAccountWasSelected(selectedAccount selectedAccount: TradeItLinkedBrokerAccount) {
        //self.fxSummaryViewManager.showOrHideFxSummarySection(selectedAccount)
        self.holdingsActivityIndicator.startAnimating()
        selectedAccount.getPositions(
            onFinished: {
                self.holdingsActivityIndicator.stopAnimating()
                self.holdingsLabel.text = selectedAccount.getFormattedAccountName() + " Holdings"
                self.positionsTableViewManager.updatePositions(withPositions: selectedAccount.positions)
                self.holdingsActivityIndicator.stopAnimating()
            }
        )
    }
}
