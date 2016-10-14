import UIKit

class TradeItBrokerManagementViewController: TradeItViewController, TradeItBrokerManagementViewControllerBrokersTableDelegate {

    let toSelectBrokerScreen = "TO_SELECT_BROKER_SCREEN"
    let toAccountManagementScreen = "TO_ACCOUNT_MANAGEMENT_SCREEN"
    let linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var brokerManagementTableManager = TradeItBrokerManagementTableViewManager()
    var selectedLinkedBroker: TradeItLinkedBroker!
    
    @IBOutlet weak var brokersTableView: UITableView!
    
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.brokerManagementTableManager.delegate = self
        self.brokerManagementTableManager.brokersTable = self.brokersTableView
    }
    
    override func viewWillAppear(animated: Bool) {
        self.brokerManagementTableManager.updateLinkedBrokers(withLinkedBrokers: self.linkedBrokerManager.linkedBrokers)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == toAccountManagementScreen {
            if let destinationViewController = segue.destinationViewController as? TradeItAccountManagementViewController,
                broker = self.selectedLinkedBroker {
                destinationViewController.linkedBroker = broker
            }
        }
    }
    
    // MARK: - TradeItBrokerManagementViewControllerBrokersTableDelegate methods
    
    func linkedBrokerWasSelected(selectedLinkedBroker: TradeItLinkedBroker) {
        self.selectedLinkedBroker = selectedLinkedBroker
        self.performSegueWithIdentifier(toAccountManagementScreen, sender: self)
    }

    @IBAction func addAccountWasTapped(sender: AnyObject) {
        self.linkBrokerUIFlow.presentLinkBrokerFlow(
            fromViewController: self,
            showWelcomeScreen: false,
            onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                linkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.brokerManagementTableManager.updateLinkedBrokers(withLinkedBrokers: self.linkedBrokerManager.linkedBrokers)
                })
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                presentedNavController.dismissViewControllerAnimated(true, completion: nil)
            }
        )
    }
}
