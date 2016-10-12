import UIKit
import TradeItIosTicketSDK2
import TradeItIosEmsApi

enum Action: Int {
    case LaunchPortfolio = 0
    case LaunchTrading
    case LaunchTradingWithSymbol
    case ManualAuthenticateAll
    case ManualBalances
    case ManualPositions
    case DeleteLinkedBrokers
    case TEST
    case ENUM_COUNT
}

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!

    let API_KEY = "tradeit-fx-test-api-key" //"tradeit-test-api-key"
    let ENVIRONMENT = TradeItEmsTestEnv
    var tradeItLauncher: TradeItLauncher!
    let viewControllerProvider = TradeItViewControllerProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tradeItLauncher = TradeItLauncher(apiKey: API_KEY, environment: ENVIRONMENT)
    }

    // Mark: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let action = Action(rawValue: indexPath.row) else { return }

        switch action {
        case .TEST:
            self.navigationController?.pushViewController(viewControllerProvider.provideViewController(forStoryboardId: .symbolSearchView), animated: true)
        case .LaunchPortfolio:
            self.tradeItLauncher.launchPortfolio(fromViewController: self)
        case .LaunchTrading:
            self.tradeItLauncher.launchTrading(fromViewController: self, withOrder: TradeItOrder())
        case .LaunchTradingWithSymbol:
            let order = TradeItOrder()
            order.symbol = "CMG"
            self.tradeItLauncher.launchTrading(fromViewController: self, withOrder: order)
        case .ManualAuthenticateAll:
            self.manualAuthenticateAll()
        case .ManualBalances:
            self.manualBalances()
        case .ManualPositions:
            self.manualPositions()
        case .DeleteLinkedBrokers:
            self.deleteLinkedBrokers()
        default:
            return
        }
    }

    // MARK: UITableViewDataSource

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
    
    // MARK: Private

    private func manualAuthenticateAll() {
        TradeItLauncher.linkedBrokerManager.authenticateAll(onSecurityQuestion: { securityQuestion, answerSecurityQuestion in
            TradeItAlert().show(securityQuestion: securityQuestion, onViewController: self, onAnswerSecurityQuestion: answerSecurityQuestion)
        }, onFinished: {
            TradeItAlert().showErrorAlert(onViewController: self, title: "authenticateAll finished", message: "\(TradeItLauncher.linkedBrokerManager.linkedBrokers.count) brokers authenticated.")
        })
    }

    private func manualBalances() {
        guard let broker = TradeItLauncher.linkedBrokerManager.linkedBrokers.first else { return print("You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("Accounts is empty. Call authenticate on the broker first.") }

        account.getAccountOverview(onSuccess: {
            print(account.balance)
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

    private func manualPositions() {
        guard let broker = TradeItLauncher.linkedBrokerManager.linkedBrokers.first else { return print("You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("Accounts is empty. Call authenticate on the broker first.") }

        account.getPositions(onSuccess: {
            print(account.positions.map({ position in
                return position.position
            }))
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

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
}
