import UIKit
import PromiseKit
import MBProgressHUD

class TradeItPortfolioAccountsViewController: TradeItViewController, TradeItPortfolioAccountsTableDelegate {
    var alertManager = TradeItAlertManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    var activityView: MBProgressHUD?
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    var selectedAccount: TradeItLinkedBrokerAccount!
    // TODO: Remove?
    var initialAccount: TradeItLinkedBrokerAccount?
    
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
        let accounts = TradeItSDK.linkedBrokerManager.getAllAuthenticatedAndEnabledAccounts()
        let linkedBrokersInError = TradeItSDK.linkedBrokerManager.getAllLinkedBrokersInError()
        self.accountsTableViewManager.updateAccounts(withAccounts: accounts, withLinkedBrokersInError: linkedBrokersInError, withSelectedAccount: self.initialAccount)
        self.updateTotalValueLabel(withAccounts: accounts)
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
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.parent?.dismiss(animated: true, completion: nil)
    }

    // MARK: - TradeItPortfolioAccountsTableDelegate methods
    
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount) {
        let portfolioController = self.viewControllerProvider.provideViewController(forStoryboardId: .portfolioView) as! TradeItPortfolioViewController
        portfolioController.linkedBrokerAccount = selectedAccount
        self.navigationController?.pushViewController(portfolioController, animated: true)
    }
}
