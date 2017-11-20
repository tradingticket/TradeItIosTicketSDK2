import UIKit
import PromiseKit

class TradeItPortfolioAccountsViewController: TradeItViewController, TradeItPortfolioAccountsTableDelegate {
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()
    var alertManager = TradeItAlertManager()
    var accountsTableViewManager = TradeItPortfolioAccountsTableViewManager()
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var adContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountsTableViewManager.delegate = self
        self.accountsTableViewManager.accountsTable = self.accountsTable
        TradeItSDK.adService.populate(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .portfolio,
            position: .bottom,
            broker: nil,
            symbol: nil,
            instrumentType: nil,
            trackPageViewAsPageType: true
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.accountsTableViewManager.initiateRefresh()
    }

    @IBAction func manageAccountsTapped(_ sender: Any) {
        let viewController = self.viewControllerProvider.provideViewController(forStoryboardId: .brokerManagementView)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: TradeItPortfolioAccountsTableDelegate
    
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
            onSuccess: updateTable,
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { error in
                self.updateTable()
            }
        )
    }

    func authenticateAll() {
        TradeItSDK.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFinished: updateTable
        )
    }

    // MARK: Private

    private func updateTable() {
        TradeItSDK.linkedBrokerManager.refreshAccountBalances(
            onFinished: {
                self.accountsTableViewManager.set(
                    linkedBrokers: TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers()
                )
            }
        )
    }
}
