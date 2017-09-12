import UIKit
import PromiseKit

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
        
        self.ordersTableViewManager?.initiateRefresh()
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
        
        func ordersPromise() -> Promise<Void> {
            return Promise<Void> { fulfill, reject in
                linkedBrokerAccount.getAllOrderStatus(
                    onSuccess: { orders in
                        self.ordersTableViewManager?.updateOrders(orders)
                        fulfill()
                    },
                    onFailure: { error in
                        reject(error)
                    }
                )
            }
        }
        
        authenticatePromise().then { _ in
            return ordersPromise()
        }.catch { error in
            let error = error as? TradeItErrorResult ??
                TradeItErrorResult(
                    title: "Fetching orders failed",
                    message: "Could not fetch orders. Please try again."
            )
            self.alertManager.showError(
                error,
                onViewController: self
            )
        }.always {
            onRefreshComplete()
        }
    }
}
