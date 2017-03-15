import UIKit
import PromiseKit
import MBProgressHUD

class TradeItPortfolioAccountsViewController: CloseableViewController, TradeItPortfolioAccountsTableDelegate {
    var alertManager = TradeItAlertManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    var activityView: MBProgressHUD?
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    var selectedAccount: TradeItLinkedBrokerAccount!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = self.accountsTable
        self.activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.refreshBrokers()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.updatePortfolioScreen()
    }

    // MARK: Private

    private func refreshBrokers() {
        self.activityView?.label.text = "Authenticating"

        TradeItSDK.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.activityView?.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: { answer in
                        self.activityView?.show(animated: true)
                        answerSecurityQuestion(answer)
                    },
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFinished: {
                self.activityView?.label.text = "Refreshing Accounts"

                TradeItSDK.linkedBrokerManager.refreshAccountBalances(
                    onFinished: {
                        self.updatePortfolioScreen()
                        self.activityView?.hide(animated: true)
                    }
                )
            }
        )
    }

    private func updatePortfolioScreen() {
        self.accountsTableViewManager.updateAccounts(
            withLinkedBrokers: TradeItSDK.linkedBrokerManager.getAllEnabledLinkedBrokers()
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
