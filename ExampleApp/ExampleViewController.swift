import UIKit
import TradeItIosTicketSDK2
import TradeItIosEmsApi

enum Action: Int {
    case LaunchPortfolio = 0
    case LaunchTrading = 1
    case DeleteLinkedBrokers = 2
    case ENUM_COUNT
}

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!

    let API_KEY = "tradeit-fx-test-api-key" //"tradeit-test-api-key"
    let ENVIRONMENT = TradeItEmsTestEnv
    var tradeItLauncher: TradeItLauncher!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tradeItLauncher = TradeItLauncher(apiKey: API_KEY, environment: ENVIRONMENT)
    }

    // Mark: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let action = Action(rawValue: indexPath.row) else { return }

        switch action {
        case .LaunchPortfolio:
            self.tradeItLauncher.launchPortfolio(fromViewController: self)
        case .LaunchTrading:
            self.launchTrading()
        case .DeleteLinkedBrokers:
            self.deleteLinkedBrokers()
        default:
            return
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Action.ENUM_COUNT.rawValue;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }

        if let action = Action(rawValue: indexPath.row) {
            cell?.textLabel?.text = "\(action)"
        }
        
        return cell!
    }
    
    // MARK: private
    private func deleteLinkedBrokers() -> Void {
        print("=====> Keychain Linked Login count before clearing: \(TradeItLauncher.linkedBrokerManager.linkedBrokers.count)")

        let appDomain = NSBundle.mainBundle().bundleIdentifier;
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!);

        let tradeItConnector = TradeItConnector(apiKey: self.API_KEY)!
        tradeItConnector.environment = self.ENVIRONMENT

        let linkedLogins = tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]

        for linkedLogin in linkedLogins {
            tradeItConnector.unlinkLogin(linkedLogin)
        }

        TradeItLauncher.linkedBrokerManager.linkedBrokers = []

        print("=====> Keychain Linked Login count after clearing: \(TradeItLauncher.linkedBrokerManager.linkedBrokers.count)")
    }

    func launchTrading() {
        TradeItLauncher.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { (TradeItSecurityQuestionResult) -> String in
                print("Security question")
                return "Security question"
            }, onFinished: {
                let brokerAccount = TradeItLauncher.linkedBrokerManager.getAllAccounts()[0]
                let viewController = self.launchViewFromStoryboard("TRADE_IT_TRADING_VIEW") as! TradeItTradingViewController
                let order = TradeItOrder(brokerAccount: brokerAccount, symbol: "AAPL")
                viewController.order = order
            }
        )

    }

    func launchViewFromStoryboard(storyboardId: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2") )
        let navigationViewController = UINavigationController()
        let viewController = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_TRADING_VIEW")

        navigationViewController.viewControllers = [viewController]
        self.presentViewController(navigationViewController, animated: true, completion: nil)
        return viewController
    }
}
