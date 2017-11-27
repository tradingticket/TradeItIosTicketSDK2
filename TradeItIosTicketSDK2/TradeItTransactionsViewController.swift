import UIKit
import MBProgressHUD
import PromiseKit

class TradeItTransactionsViewController: TradeItViewController, TradeItTransactionsTableDelegate {
    private let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    private let alertManager = TradeItAlertManager()
    private var transactionsTableViewManager: TradeItTransactionsTableViewManager?
    
    @IBOutlet weak var transactionsTable: UITableView!
    @IBOutlet var transactionsBackgroundView: UIView!
    
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItTransactionsViewController loaded without setting linkedBrokerAccount.")
        }
        self.transactionsTableViewManager = TradeItTransactionsTableViewManager(linkedBrokerAccount: linkedBrokerAccount, noResultsBackgroundView: transactionsBackgroundView )
        self.transactionsTableViewManager?.delegate = self
        self.transactionsTableViewManager?.transactionsTable = transactionsTable
        self.loadTransactions()
    }
    
    // MARK: IBAction
    
    @IBAction func filterButtonWasTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        let allTransactionsAction = provideTransactionsUIAlertAction(filterType: .ALL_TRANSACTIONS)
        alertController.addAction(allTransactionsAction)

        if let transactionsPresenter = transactionsTableViewManager?.transactionHistoryResultPresenter {
            if transactionsPresenter.numberOfTransactions(forFilterType: .TRADES) > 0 {
                let tradesAction = provideTransactionsUIAlertAction(filterType: .TRADES)
                alertController.addAction(tradesAction)
            }
            if transactionsPresenter.numberOfTransactions(forFilterType: .DIVIDENDS_AND_INTEREST) > 0 {
                let dividendsAndInterestAction = provideTransactionsUIAlertAction(filterType: .DIVIDENDS_AND_INTEREST)
                alertController.addAction(dividendsAndInterestAction)
            }
            if transactionsPresenter.numberOfTransactions(forFilterType: .TRANSFERS) > 0 {
                let transfersAction = provideTransactionsUIAlertAction(filterType: .TRANSFERS)
                alertController.addAction(transfersAction)
            }
            if transactionsPresenter.numberOfTransactions(forFilterType: .FEES) > 0 {
                let feesAction = provideTransactionsUIAlertAction(filterType: .FEES)
                alertController.addAction(feesAction)
            }
            if transactionsPresenter.numberOfTransactions(forFilterType: .OTHER) > 0 {
                let otherAction = provideTransactionsUIAlertAction(filterType: .OTHER)
                alertController.addAction(otherAction)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if UIDevice.current.userInterfaceIdiom == .pad,
            let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }

        self.present(alertController, animated: true, completion: nil)
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
        self.refreshRequested( onRefreshComplete: {
            activityView.hide(animated: true)
        })
    }

    // MARK: Private

    private func provideTransactionsUIAlertAction(filterType: TransactionFilterType) -> UIAlertAction {
        return UIAlertAction(title: filterType.rawValue, style: .default, handler: filterActionWasTapped(filterType: filterType))
    }

    private func filterActionWasTapped(filterType: TransactionFilterType) -> (_ alertAction:UIAlertAction) -> () {
        return { alertAction in
            self.transactionsTableViewManager?.filterTransactionHistoryResult(filterType: filterType)
        }
    }
}

enum TransactionFilterType: String {
    case ALL_TRANSACTIONS = "All Transactions"
    case TRADES = "Trades"
    case DIVIDENDS_AND_INTEREST = "Dividends and Interest"
    case TRANSFERS = "Transfers"
    case FEES = "Fees"
    case OTHER = "Other"
}
