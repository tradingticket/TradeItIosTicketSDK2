import UIKit
import PromiseKit

class TradeItPortfolioAccountsViewController: CloseableViewController, TradeItPortfolioAccountsTableDelegate {
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    var alertManager = TradeItAlertManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var totalValueLabel: UILabel!

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

    // TODO: shouldn't this be provided by CloseableViewController?
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.parent?.dismiss(animated: true, completion: nil)
    }

    // MARK: - TradeItPortfolioAccountsTableDelegate methods
    
    func linkedBrokerAccountWasSelected(selectedAccount: TradeItLinkedBrokerAccount) {
        let portfolioAccountDetailsController = self.viewControllerProvider.provideViewController(forStoryboardId: .portfolioAccountDetailsView) as! TradeItPortfolioAccountDetailsViewController
        portfolioAccountDetailsController.linkedBrokerAccount = selectedAccount
        self.navigationController?.pushViewController(portfolioAccountDetailsController, animated: true)
    }

    func initiateRelink(linkedBroker: TradeItLinkedBroker) {
        self.linkBrokerUIFlow.presentRelinkBrokerFlow(
            inViewController: self,
            linkedBroker: linkedBroker,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl
        )
    }

    func initiateAuthenticate(linkedBroker: TradeItLinkedBroker) {
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
