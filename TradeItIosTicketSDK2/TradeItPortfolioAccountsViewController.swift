import UIKit
import PromiseKit

class TradeItPortfolioAccountsViewController: CloseableViewController, TradeItPortfolioAccountsTableDelegate {
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    var alertManager = TradeItAlertManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()

    @IBOutlet weak var accountsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = self.accountsTable

        self.accountsTableViewManager.initiateRefresh()
    }

    @IBAction func manageAccountsTapped(_ sender: Any) {
        let viewController = self.viewControllerProvider.provideViewController(forStoryboardId: .brokerManagementView)
        self.navigationController?.pushViewController(viewController, animated: true)
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

    // MARK: - TradeItPortfolioAccountsTableDelegate methods
    
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount) {
        let portfolioAccountDetailsController = self.viewControllerProvider.provideViewController(forStoryboardId: .portfolioAccountDetailsView) as! TradeItPortfolioAccountDetailsViewController
        portfolioAccountDetailsController.linkedBrokerAccount = selectedAccount
        self.navigationController?.pushViewController(portfolioAccountDetailsController, animated: true)
    }

    func relink(linkedBroker: TradeItLinkedBroker) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: linkedBroker,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl
        )
    }

    func authenticate(linkedBroker: TradeItLinkedBroker) {
        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                self.accountsTableViewManager.initiateRefresh()
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { error in
                self.accountsTableViewManager.update(withLinkedBrokers: TradeItSDK.linkedBrokerManager.getAllEnabledLinkedBrokers())
            }
        )
    }
}
