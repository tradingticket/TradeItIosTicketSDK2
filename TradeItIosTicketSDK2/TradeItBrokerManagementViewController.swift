import UIKit

class TradeItBrokerManagementViewController: TradeItViewController, TradeItBrokerManagementViewControllerBrokersTableDelegate {
    let toSelectBrokerScreen = "TO_SELECT_BROKER_SCREEN"
    let toAccountManagementScreen = "TO_ACCOUNT_MANAGEMENT_SCREEN"
    let linkedBrokerManager = TradeItSDK.linkedBrokerManager
    var brokerManagementTableManager = TradeItBrokerManagementTableViewManager()
    var selectedLinkedBroker: TradeItLinkedBroker!
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    @IBOutlet weak var brokersTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.brokerManagementTableManager.delegate = self
        self.brokerManagementTableManager.brokersTable = self.brokersTableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.brokerManagementTableManager.updateLinkedBrokers(withLinkedBrokers: (self.linkedBrokerManager?.linkedBrokers)!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toAccountManagementScreen {
            if let destinationViewController = segue.destination as? TradeItAccountManagementViewController,
                let broker = self.selectedLinkedBroker {
                destinationViewController.linkedBroker = broker
            }
        }
    }
    
    // MARK: - TradeItBrokerManagementViewControllerBrokersTableDelegate methods
    
    func linkedBrokerWasSelected(_ selectedLinkedBroker: TradeItLinkedBroker) {
        self.selectedLinkedBroker = selectedLinkedBroker
        self.performSegue(withIdentifier: toAccountManagementScreen, sender: self)
    }

    @IBAction func addAccountWasTapped(_ sender: AnyObject) {
        self.linkBrokerUIFlow.presentLinkBrokerFlow(
            fromViewController: self,
            showWelcomeScreen: false,
            onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                presentedNavController.dismiss(animated: true, completion: nil)
                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.brokerManagementTableManager.updateLinkedBrokers(withLinkedBrokers: (self.linkedBrokerManager?.linkedBrokers)!)
                })
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                presentedNavController.dismiss(animated: true, completion: nil)
            }
        )
    }
}
