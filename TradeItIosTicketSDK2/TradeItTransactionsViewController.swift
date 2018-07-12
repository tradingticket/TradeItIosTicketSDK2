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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            alertMissingRequiredParameter()
            return
        }

        TradeItBundleProvider.registerBrandedAccountNibCells(forTableView: transactionsTable)

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
            [
                .TRADES,
                .DIVIDENDS_AND_INTEREST,
                .TRANSFERS,
                .FEES,
                .OTHER
            ].filter { transactionsPresenter.numberOfTransactions(forFilterType: $0) > 0 }.forEach { filterType in
                let action = provideTransactionsUIAlertAction(filterType: filterType)
                alertController.addAction(action)
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
                alertMissingRequiredParameter()
                return
        }
        
        func transactionsPromise() -> Promise<TradeItTransactionsHistoryResult> {
            return Promise<TradeItTransactionsHistoryResult> { seal in
                linkedBrokerAccount.getTransactionsHistory(
                    onSuccess: seal.fulfill,
                    onFailure: seal.reject
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
        }.done { transactionsHistoryResult in
            self.transactionsTableViewManager?.updateTransactionHistoryResult(transactionsHistoryResult) // TODO order by date desc or check the server order
        }.ensure(onRefreshComplete)
        .catch { error in
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

    private func alertMissingRequiredParameter() {
        let systemMessage = "TradeItTransactionsViewController loaded without setting linkedBrokerAccount."
        print("TradeItIosTicketSDK ERROR: \(systemMessage)")
        self.alertManager.showError(
            TradeItErrorResult.error(withSystemMessage: systemMessage),
            onViewController: self,
            onFinished: {
                self.closeButtonWasTapped()
        }
        )
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
