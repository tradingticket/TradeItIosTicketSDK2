import UIKit
import PromiseKit
import TradeItIosEmsApi

class TradeItPortfolioViewController: UIViewController, TradeItPortfolioViewControllerAccountsTableDelegate {
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
                        self.accountsTableViewManager.updateAccounts(withAccounts: self.linkedBrokerManager.getAllAccounts())
                        self.ezLoadingActivityManager.hide()
                    }
                )
            }
        )
    }
    
    // MARK: IBAction
    
    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        self.parentViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - TradeItPortfolioViewControllerAccountsTableDelegate methods
    
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