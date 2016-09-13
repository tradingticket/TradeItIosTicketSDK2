import UIKit
import PromiseKit
import TradeItIosEmsApi

class TradeItPortfolioViewController: UIViewController, TradeItPortfolioViewControllerAccountsTableDelegate {
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var ezLoadingActivityManager = EZLoadingActivityManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    var fxSummaryViewManager = TradeItPortfolioFxSummaryViewManager()
    
    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var fxSummaryView: TradeItFxSummaryView!
    @IBOutlet weak var holdingsActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = accountsTable
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
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount) {
        self.fxSummaryViewManager.showOrHideFxSummarySection(selectedAccount)
//        self.holdingsActivityIndicator.startAnimating()
//        self.linkedBrokerManager.refreshPositionsForSelectedAccount(selectedAccount)(
//            onFinished: {
//                self.holdingsActivityIndicator.stopAnimating()
//                self.positionsTableViewManager.updatePositions(selectedAccount)
//                self.holdingsActivityIndicator.stopAnimating()
//            }
//        )
    }
}