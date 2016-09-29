import UIKit

class TradeItBrokerManagementViewController: UIViewController, TradeItBrokerManagementViewControllerBrokersTableDelegate {

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
        let controllersStack = self.navigationController?.viewControllers
        self.linkBrokerUIFlow.launchLinkBrokerFlow(
            inViewController: self,
            showWelcomeScreen: false,
            promptForAccountSelection: false,
            onLinked: { (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void in
                presentedNavController.setViewControllers(controllersStack!, animated: true)
                self.brokerManagementTableManager.updateLinkedBrokers(withLinkedBrokers: self.linkedBrokerManager.linkedBrokers)
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                //nothing todo ?
            }
        )
    }
}
