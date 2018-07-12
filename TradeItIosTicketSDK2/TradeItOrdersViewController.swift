import UIKit
import PromiseKit
import MBProgressHUD

class TradeItOrdersViewController: TradeItViewController, TradeItOrdersTableDelegate {
    var ordersTableViewManager: TradeItOrdersTableViewManager?
    let alertManager = TradeItAlertManager()
    var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    
    @IBOutlet weak var ordersTable: UITableView!
    @IBOutlet var orderTableBackgroundView: UIView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let linkedBrokerAccount = self.linkedBrokerAccount else {
            alertMissingRequiredParameter()
            return
        }

        TradeItBundleProvider.registerBrandedAccountNibCells(forTableView: ordersTable)

        self.title = "Orders"
        self.ordersTableViewManager = TradeItOrdersTableViewManager(
            noResultsBackgroundView: orderTableBackgroundView,
            linkedBrokerAccount: linkedBrokerAccount
        )
        self.ordersTableViewManager?.delegate = self
        self.ordersTableViewManager?.ordersTable = self.ordersTable
        self.loadOrders()
    }

    // MARK: TradeItOrdersTableDelegate
    
    func refreshRequested(onRefreshComplete: @escaping () -> Void) {
        guard let linkedBrokerAccount = self.linkedBrokerAccount
            , let linkedBroker = linkedBrokerAccount.linkedBroker else {
                alertMissingRequiredParameter()
                return
        }
        
        func ordersPromise() -> Promise<[TradeItOrderStatusDetails]> {
            return Promise<[TradeItOrderStatusDetails]> { seal in
                linkedBrokerAccount.getAllOrderStatus(
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
            return ordersPromise()
        }.done { orders in
            self.ordersTableViewManager?.updateOrders(orders)
        }.ensure {
            onRefreshComplete()
        }.catch { error in
            let error = error as? TradeItErrorResult ??
                TradeItErrorResult(
                    title: "Fetching orders failed",
                    message: "Could not fetch orders. Please try again."
            )
            self.alertManager.showAlertWithAction(
                error: error,
                withLinkedBroker: self.linkedBrokerAccount?.linkedBroker,
                onViewController: self
            )
        }
    }
    
    func cancelActionWasTapped(
        forOrderNumber orderNumber: String,
        title: String,
        message: String
    ) {
        let proceedCancellation: () -> Void = {
            let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
            activityView.label.text = "Canceling"
            self.linkedBrokerAccount?.cancelOrder(
                orderNumber: orderNumber,
                onSuccess: {
                    activityView.hide(animated: true)
                    self.loadOrders()
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
                    activityView.hide(animated: true)
                    self.alertManager.showAlertWithAction(
                        error: error,
                        withLinkedBroker: self.linkedBrokerAccount?.linkedBroker,
                        onViewController: self
                    )
                }
            )
        }
        
        self.alertManager.showAlertWithMessageOnly(
            onViewController: self,
            withTitle: title,
            withMessage: message,
            withActionTitle: "Yes",
            withCancelTitle: "No",
            errorToReport: nil,
            onAlertActionTapped: proceedCancellation,
            showCancelAction: true,
            onCancelActionTapped: {}
        )
    }
    
    // MARK: private

    private func loadOrders() {
        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Loading orders"
        self.refreshRequested {
            activityView.hide(animated: true)
        }
    }

    private func alertMissingRequiredParameter() {
        let systemMessage = "TradeItOrdersViewController loaded without setting linkedBrokerAccount."
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
