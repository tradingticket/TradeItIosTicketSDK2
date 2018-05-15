import UIKit

class TradeItYahooAccountSelectionViewController: TradeItYahooViewController, TradeItYahooAccountSelectionTableViewManagerDelegate {
    @IBOutlet weak var accountsTableView: UITableView!

    let linkBrokerUIFlow = TradeItYahooLinkBrokerUIFlow()
    var alertManager: TradeItAlertManager?
    var selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?
    var accountSelectionTableManager = TradeItYahooAccountSelectionTableViewManager()
    weak var delegate: TradeItYahooAccountSelectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSelectionTableManager.delegate = self
        self.accountSelectionTableManager.accountsTable = self.accountsTableView
        self.alertManager = TradeItAlertManager(linkBrokerUIFlow: linkBrokerUIFlow)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let displayableBrokers = TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers()
        self.accountSelectionTableManager.updateLinkedBrokers(
            withLinkedBrokers: displayableBrokers,
            withSelectedLinkedBrokerAccount: self.selectedLinkedBrokerAccount
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fireViewEventNotification(view: .selectAccount, title: self.title)
    }

    // MARK: TradeItYahooAccounSelectionTableViewManagerDelegate

    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItYahooAccountSelectionTableViewManager,
                          onRefreshComplete: @escaping ([TradeItLinkedBroker]?) -> Void) {
        // TODO: Need to think about how not to have to wrap every linked broker action in a call to authenticate
        TradeItSDK.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, onAnswerSecurityQuestion, onCancelSecurityQuestion in
                self.alertManager?.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: onAnswerSecurityQuestion,
                    onCancelSecurityQuestion: onCancelSecurityQuestion
                )
            },
            onFailure:  { error, linkedBroker in
                self.alertManager?.showAlertWithAction(
                    error: error,
                    withLinkedBroker: linkedBroker,
                    onViewController: self,
                    onFinished: {
                        // QUESTION: is this just going to re-run authentication for all linked brokers again if one failed?
                        onRefreshComplete(TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers())
                    }
                )
            },
            onFinished: {
                TradeItSDK.linkedBrokerManager.refreshAccountBalances(
                    onFinished:  {
                        onRefreshComplete(TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers())
                    }
                )   
            }
        )
    }

    func authenticate(linkedBroker: TradeItLinkedBroker, onFinished: @escaping () -> Void) {
        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.accountSelectionTableManager.updateLinkedBrokers(
                            withLinkedBrokers: TradeItSDK.linkedBrokerManager.getAllDisplayableLinkedBrokers(),
                            withSelectedLinkedBrokerAccount: self.selectedLinkedBrokerAccount
                        )
                    }
                )
                onFinished()
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager?.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
                onFinished()
            },
            onFailure:  { error in
                self.alertManager?.showAlertWithAction(
                    error: error,
                    withLinkedBroker: linkedBroker,
                    onViewController: self
                )
                onFinished()
            }
        )
    }

    func linkedBrokerAccountWasSelected(_ linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.delegate?.accountSelectionViewController(self, didSelectLinkedBrokerAccount: linkedBrokerAccount)
    }
    
    func addBrokerageAccountWasSelected() {
        self.linkBrokerUIFlow.presentLinkBrokerFlow(
            fromViewController: self,
            showWelcomeScreen: false,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl
        )
    }
}

protocol TradeItYahooAccountSelectionViewControllerDelegate: class {
    func accountSelectionViewController(
        _ accountSelectionViewController: TradeItYahooAccountSelectionViewController,
        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount
    )
}
