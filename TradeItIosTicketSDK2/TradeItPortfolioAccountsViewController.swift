import UIKit
import PromiseKit

class TradeItPortfolioAccountsViewController: CloseableViewController, TradeItPortfolioAccountsTableDelegate {
    var alertManager = TradeItAlertManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    var selectedAccount: TradeItLinkedBrokerAccount!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = self.accountsTable
    }

    override func viewWillAppear(_ animated: Bool) {
        self.accountsTableViewManager.initiateRefresh()
    }

    // MARK: TradeItPortfolioAccountsTableDelegate

    func refreshRequested(onRefreshComplete: @escaping ([TradeItLinkedBroker]) -> Void) {
        TradeItSDK.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFinished: {
                TradeItSDK.linkedBrokerManager.refreshAccountBalances(
                    onFinished: {
                        onRefreshComplete(TradeItSDK.linkedBrokerManager.getAllEnabledLinkedBrokers())
                    }
                )
            }
        )
    }

    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.parent?.dismiss(animated: true, completion: nil)
    }

    // MARK: - TradeItPortfolioAccountsTableDelegate methods
    
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount) {
        let portfolioAccountDetailsController = self.viewControllerProvider.provideViewController(forStoryboardId: .portfolioAccountDetailsView) as! TradeItPortfolioAccountDetailsViewController
        portfolioAccountDetailsController.linkedBrokerAccount = selectedAccount
        self.navigationController?.pushViewController(portfolioAccountDetailsController, animated: true)
    }
}
