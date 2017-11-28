import UIKit
import MBProgressHUD
import PromiseKit

class TradeItTransactionsViewController: TradeItViewController, TradeItTransactionsTableDelegate {
    private let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    private let alertManager = TradeItAlertManager()
    private var transactionsTableViewManager: TradeItTransactionsTableViewManager?
    
    @IBOutlet weak var transactionsTable: UITableView!
    
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItTransactionsViewController loaded without setting linkedBrokerAccount.")
        }
        self.transactionsTableViewManager = TradeItTransactionsTableViewManager(linkedBrokerAccount: linkedBrokerAccount)
        self.transactionsTableViewManager?.delegate = self
        self.transactionsTableViewManager?.transactionsTable = transactionsTable
        self.loadTransactions()
    }
    
    // MARK: IBAction
    
    @IBAction func filterButtonWasTapped(_ sender: Any) {
        //TODO: https://www.pivotaltracker.com/story/show/148168413
    }
    // MARK: TradeItTransactionsTableDelegate
    
    func refreshRequested(onRefreshComplete: @escaping () -> Void) {
        guard let linkedBrokerAccount = self.linkedBrokerAccount
            , let linkedBroker = linkedBrokerAccount.linkedBroker else {
                preconditionFailure("TradeItIosTicketSDK ERROR: TradeItTransactionsViewController loaded without setting linkedBrokerAccount.")
        }
        
        func transactionsPromise() -> Promise<TradeItTransactionsHistoryResult> {
            return Promise<TradeItTransactionsHistoryResult> { fulfill, reject in
                linkedBrokerAccount.getTransactionsHistory(
                    onSuccess: fulfill,
                    onFailure: reject
                )
            }
        }
        
        linkedBroker.authenticatePromise(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            }
        ).then { _ in
            return transactionsPromise()
        }.then { transactionsHistoryResult in
            self.transactionsTableViewManager?.updateTransactionHistoryResult(transactionsHistoryResult) // TODO order by date desc or check the server order
        }.always {
            onRefreshComplete()
        }.catch { error in
            let error = error as? TradeItErrorResult ??
                TradeItErrorResult(
                    title: "Fetching transactions failed",
                    message: "Could not fetch transactions. Please try again."
            )
            self.alertManager.showAlertWithAction(
                error: error,
                withLinkedBroker: self.linkedBrokerAccount?.linkedBroker,
                onViewController: self
            )
        }
    }

    func transactionWasSelected(_ transaction: TradeItTransaction) {
        guard let transactionDetailsController = self.viewControllerProvider.provideViewController(forStoryboardId: .transactionDetailsView) as? TradeItTransactionDetailsViewController else {
            return
        }
        transactionDetailsController.transaction = transaction
        transactionDetailsController.accountBaseCurrency = self.linkedBrokerAccount?.accountBaseCurrency ?? TradeItPresenter.DEFAULT_CURRENCY_CODE
        self.navigationController?.pushViewController(transactionDetailsController, animated: true)
    }

    // MARK: private
    
    private func loadTransactions() {
        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Loading transactions"
        self.refreshRequested {
            activityView.hide(animated: true)
        }
    }
}
