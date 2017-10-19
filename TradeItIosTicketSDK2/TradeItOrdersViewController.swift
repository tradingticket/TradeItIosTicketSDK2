import UIKit
import PromiseKit
import MBProgressHUD

class TradeItOrdersViewController: TradeItViewController, TradeItOrdersTableDelegate {
    var ordersTableViewManager: TradeItOrdersTableViewManager?
    let alertManager = TradeItAlertManager()
    let tradingUIFlow = TradeItTradingUIFlow()

    var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    
    @IBOutlet weak var ordersTable: UITableView!
    @IBOutlet var orderTableBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = self.linkedBrokerAccount else {
            preconditionFailure("TradeItIosTicketSDK ERROR: TradeItOrdersViewController loaded without setting linkedBrokerAccount.")
        }
        self.ordersTableViewManager = TradeItOrdersTableViewManager(noResultsBackgroundView: orderTableBackgroundView)
        self.ordersTableViewManager?.delegate = self
        self.ordersTableViewManager?.ordersTable = self.ordersTable
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadOrders()
    }
    
    //MARK: IBAction
    
    @IBAction func tradeButtonWasTapped(_ sender: Any) {
        let order = TradeItOrder(linkedBrokerAccount: linkedBrokerAccount)
        self.tradingUIFlow.presentTradingFlow(fromViewController: self, withOrder: order)
    }
    
    // MARK: TradeItOrdersTableDelegate
    
    func refreshRequested(onRefreshComplete: @escaping () -> Void) {
        guard let linkedBrokerAccount = self.linkedBrokerAccount
            , let linkedBroker = linkedBrokerAccount.linkedBroker else {
                preconditionFailure("TradeItIosTicketSDK ERROR: TradeItOrdersViewController loaded without setting linkedBrokerAccount.")
        }
        func authenticatePromise() -> Promise<Void>{
            return Promise<Void> { fulfill, reject in
                linkedBroker.authenticateIfNeeded(
                    onSuccess: fulfill,
                    onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                        self.alertManager.promptUserToAnswerSecurityQuestion(
                            securityQuestion,
                            onViewController: self,
                            onAnswerSecurityQuestion: answerSecurityQuestion,
                            onCancelSecurityQuestion: cancelSecurityQuestion
                        )
                    },
                    onFailure: reject
                )
            }
        }
        
        func ordersPromise() -> Promise<[TradeItOrderStatusDetails]> {
            return Promise<[TradeItOrderStatusDetails]> { fulfill, reject in
                linkedBrokerAccount.getAllOrderStatus(
                    onSuccess: fulfill,
                    onFailure: reject
                )
            }
        }
        
        authenticatePromise().then { _ in
            return ordersPromise()
        }.then { orders in
            self.ordersTableViewManager?.updateOrders(orders)
        }.always {
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
    
    func cancelActionWasTapped(forOrderNumber orderNumber: String) {
        let proceedCancellation: () -> Void = {
            let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
            activityView.label.text = "Canceling order"
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
            withTitle: "Are you sure?",
            withMessage: "Please confirm you are canceling this order.",
            withActionTitle: "Proceed",
            withCancelTitle: "Back",
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
}
