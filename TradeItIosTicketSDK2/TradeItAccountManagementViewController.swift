import UIKit
import TradeItIosEmsApi

class TradeItAccountManagementViewController: UIViewController {
    var tradeItAlert = TradeItAlert()
    var selectedLinkedBroker: TradeItLinkedBroker!
    var accountsManagementTableManager = TradeItAccountManagementTableViewManager()
    var linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    
    @IBOutlet weak var accountsTableView: UITableView!
    var refreshControl: UIRefreshControl!

    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    //let toLoginScreenSegueId = "TO_LOGIN_SCREEN_WITH_RELINK_ID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing ...")
        self.refreshControl.addTarget(self, action: #selector(TradeItAccountManagementViewController.refreshAccountsTable(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.accountsTableView.addSubview(self.refreshControl)
    
        self.accountsManagementTableManager.accountsTable = self.accountsTableView
        if let selectedLinkedBroker = self.selectedLinkedBroker {
            self.navigationItem.title = self.selectedLinkedBroker.linkedLogin.broker
            self.accountsManagementTableManager.updateAccounts(withAccounts: selectedLinkedBroker.accounts)
        }
        
    }
    
    func refreshAccountsTable(sender:AnyObject) {
        selectedLinkedBroker.authenticate(
            onSuccess: { () -> Void in
                self.selectedLinkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.refreshControl.endRefreshing()
                        self.accountsManagementTableManager.updateAccounts(withAccounts: self.selectedLinkedBroker.accounts)
                })
            },
            onSecurityQuestion: { (tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String in
                print("Security question result: \(tradeItSecurityQuestionResult)")
                
                // TODO: Get answer from user...
                return "Some Answer"
            },
            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                self.refreshControl.endRefreshing()
                self.tradeItAlert.showTradeItErrorResultAlert(onController: self, withError: tradeItErrorResult)
            }
        )
    }
    
    // MARK: IBAction
    @IBAction func relinkAccountWasTapped(sender: AnyObject) {
        let linkedLogin = self.selectedLinkedBroker.linkedLogin
        let broker = TradeItBroker(shortName: linkedLogin.broker, longName: linkedLogin.broker)
        let controllersStack = self.navigationController?.viewControllers
        self.linkBrokerUIFlow.launchIntoLoginScreen(
            inViewController: self,
            selectedBroker: broker,
            selectedReLinkedBroker: self.selectedLinkedBroker,
            mode:  TradeItLoginViewControllerMode.relink,
            onLinked: { (presentedNavController: UINavigationController, selectedAccount: TradeItLinkedBrokerAccount?) -> Void in
                presentedNavController.setViewControllers(controllersStack!, animated: true)
                self.selectedLinkedBroker.refreshAccountBalances(
                    onFinished: {
                        self.accountsManagementTableManager.updateAccounts(withAccounts: self.selectedLinkedBroker.accounts)
                })
            },
            onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                //Nothing to do ?
            }
        )
    }
    
    @IBAction func unlinkAccountWasTapped(sender: AnyObject) {
        self.tradeItAlert.showValidationAlert(onController: self, withTitle: "Unlink \(self.selectedLinkedBroker.linkedLogin.broker)", withMessage: "Are you sure you want to unlink your account and remove all the associated data ?", withActionOkTitle: "Unlink",
            onValidate: {
                self.linkedBrokerManager.unlinkBroker(self.selectedLinkedBroker)
                if self.linkedBrokerManager.linkedBrokers.count > 0 {
                    self.performSegueWithIdentifier("UNWIND_TO_BROKER_MANAGEMENT", sender: self)
                }
                else {
                    //Go to the splash screen
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            },
            onCancel: {
                //Nothing to do
            }
        )
    }
    
    
}
