import UIKit
@testable import TradeItIosTicketSDK2

enum Action: Int {
    case launchPortfolio = 0
    case launchPortfolioForLinkedBrokerAccount
    case launchTrading
    case launchTradingWithSymbol
    case launchAccountManagement
    case launchBrokerLinking
    case manualAuthenticateAll
    case manualBalances
    case manualPositions
    case launchAlertQueue
    case deleteLinkedBrokers
    case TEST
    case enum_COUNT
}

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!

    let API_KEY = "tradeit-fx-test-api-key" //"tradeit-test-api-key"
    let ENVIRONMENT = TradeItEmsTestEnv
    var tradeItLauncher: TradeItLauncher!

    var alertManager: TradeItAlertManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tradeItLauncher = TradeItLauncher(apiKey: API_KEY, environment: ENVIRONMENT)
        self.alertManager = TradeItAlertManager()

        printLinkedBrokers()
    }

    // Mark: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let action = Action(rawValue: indexPath.row) else { return }

        switch action {
        case .TEST:
            test()
        case .launchPortfolio:
            self.tradeItLauncher.launchPortfolio(fromViewController: self)
        case .launchPortfolioForLinkedBrokerAccount:
            guard let linkedBrokerAccount = TradeItLauncher.linkedBrokerManager.linkedBrokers.first?.accounts.last else {
                return print("You must link a broker with an account first")
            }
            self.tradeItLauncher.launchPortfolio(fromViewController: self, forLinkedBrokerAccount: linkedBrokerAccount)
        case .launchTrading:
            self.tradeItLauncher.launchTrading(fromViewController: self, withOrder: TradeItOrder())
        case .launchTradingWithSymbol:
            let order = TradeItOrder()
            order.symbol = "CMG"
            self.tradeItLauncher.launchTrading(fromViewController: self, withOrder: order)
        case .launchAccountManagement:
            self.tradeItLauncher.launchAccountManagement(fromViewController: self)
        case .launchBrokerLinking:
            self.tradeItLauncher.launchBrokerLinking(fromViewController: self, onLinked: { linkedBroker in
                print("Newly linked broker: \(linkedBroker)")
            }, onFlowAborted: {
                print("User aborted linking")
            })
        case .manualAuthenticateAll:
            self.manualAuthenticateAll()
        case .manualBalances:
            self.manualBalances()
        case .manualPositions:
            self.manualPositions()
        case .launchAlertQueue:
            self.launchAlertQueue()
        case .deleteLinkedBrokers:
            self.deleteLinkedBrokers()
        default:
            return
        }
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Action.enum_COUNT.rawValue;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }

        if let action = Action(rawValue: indexPath.row) {
            cell?.textLabel?.text = "\(action)"
        }
        
        return cell!
    }
    
    // MARK: Private

    private func test() {
        // Put code you want to test here...
    }

    private func printLinkedBrokers() {
        print("\n\n=====> LINKED BROKERS:")

        for linkedBroker in TradeItLauncher.linkedBrokerManager.linkedBrokers {
            let linkedLogin = linkedBroker.linkedLogin
            print("=====> \(linkedLogin.broker)(\(linkedBroker.accounts.count) accounts) - \(linkedLogin.userId) - \(linkedLogin.label ?? "NO LABEL")")
        }

        print("=====> ===============\n\n")
    }

    fileprivate func manualAuthenticateAll() {
        TradeItLauncher.linkedBrokerManager.authenticateAll(onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
            self.alertManager.promptUserToAnswerSecurityQuestion(
                securityQuestion,
                onViewController: self,
                onAnswerSecurityQuestion: answerSecurityQuestion,
                onCancelSecurityQuestion: cancelQuestion)
        }, onFinished: {
            self.alertManager.showAlert(
                onViewController: self,
                withTitle: "authenticateAll finished",
                withMessage: "\(TradeItLauncher.linkedBrokerManager.linkedBrokers.count) brokers authenticated.",
                withActionTitle: "OK")
        })
    }

    fileprivate func manualBalances() {
        guard let broker = TradeItLauncher.linkedBrokerManager.linkedBrokers.first else { return print("You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("Accounts is empty. Call authenticate on the broker first.") }

        account.getAccountOverview(onSuccess: {
            print(account.balance ?? "Something went wrong!")
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

    fileprivate func manualPositions() {
        guard let broker = TradeItLauncher.linkedBrokerManager.linkedBrokers.first else { return print("You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("Accounts is empty. Call authenticate on the broker first.") }

        account.getPositions(onSuccess: { positions in
            print(positions.map({ position in
                return position.position
            }))
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

    fileprivate func launchAlertQueue() {
        alertManager.showAlert(
            onViewController: self,
            withTitle: "Alert 1",
            withMessage: "Alert 1",
            withActionTitle: "OK",
            onAlertActionTapped: {}
        )
        let securityQuestion = TradeItSecurityQuestionResult()
        securityQuestion.securityQuestion = "Security Question"
        alertManager.promptUserToAnswerSecurityQuestion(
            securityQuestion, onViewController: self, onAnswerSecurityQuestion: { _ in }, onCancelSecurityQuestion: {}
        )
        alertManager.showAlert(
            onViewController: self,
            withTitle: "Alert 2",
            withMessage: "Alert 2",
            withActionTitle: "OK",
            onAlertActionTapped: {}
        )
    }

    fileprivate func deleteLinkedBrokers() -> Void {
        print("=====> Keychain Linked Login count before clearing: \(TradeItLauncher.linkedBrokerManager.linkedBrokers.count)")

        let appDomain = Bundle.main.bundleIdentifier;
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)

        let connector = TradeItConnector(apiKey: self.API_KEY)
        connector.environment = self.ENVIRONMENT

        let linkedLogins = connector.getLinkedLogins() as! [TradeItLinkedLogin]

        for linkedLogin in linkedLogins {
            connector.unlinkLogin(linkedLogin)
        }

        TradeItLauncher.linkedBrokerManager.linkedBrokers = []

        print("=====> Keychain Linked Login count after clearing: \(TradeItLauncher.linkedBrokerManager.linkedBrokers.count)")
    }
}
