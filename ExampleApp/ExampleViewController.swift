import UIKit
@testable import TradeItIosTicketSDK2

struct Section {
    let label: String
    let actions: [Action]
}

class Action {
    public var label: String
    public var action: () -> Void

    init(
        label: String,
        action: @escaping () -> Void,
        oAuthCallbackUrl: String = "tradeItExampleScheme://completeOAuth",
        isUiConfigServiceEnabled: Bool = true
    ) {
        self.label = label
        self.action = {
            TradeItSDK.oAuthCallbackUrl = URL(string: oAuthCallbackUrl)!
            action()
            TradeItSDK.uiConfigService.isEnabled = isUiConfigServiceEnabled
        }
    }
}

class YahooAction: Action {
    override init(
        label: String,
        action: @escaping () -> Void,
        oAuthCallbackUrl: String = "tradeItExampleScheme://completeYahooOAuth",
        isUiConfigServiceEnabled: Bool = false
    ) {
        super.init(
            label: label,
            action: action,
            oAuthCallbackUrl: oAuthCallbackUrl,
            isUiConfigServiceEnabled: isUiConfigServiceEnabled
        )
    }
}

@objc public class ExampleAdService: NSObject, AdService {

    public func populate(
        adContainer: UIView,
        rootViewController: UIViewController,
        pageType: TradeItAdPageType,
        position: TradeItAdPosition,
        broker: String?,
        symbol: String?,
        instrumentType: String?,
        trackPageViewAsPageType: Bool
    ) {
        let viewControllerName = String(describing: type(of: rootViewController))
        print("=====> ExampleAdService.populate(_,_,_,_,_,_,_,_) called on \(viewControllerName)")

        adContainer.isHidden = false
        adContainer.backgroundColor = UIColor.magenta
    }
}

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TradeItOAuthDelegate {
    @IBOutlet weak var table: UITableView!

    internal var sections: [Section]?
    var defaultSections: [Section]!
    var advancedSections: [Section]!
    let alertManager: TradeItAlertManager = TradeItAlertManager()
    var advancedViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "tradeit_logo.png")
        let logoView = UIImageView(image: logo)
        self.navigationItem.titleView = logoView

        defaultSections = [
            Section(
                label: "SDK Screens",
                actions: [
                    Action(
                        label: "Link a broker",
                        action: {
                            TradeItSDK.launcher.launchBrokerLinking(
                                fromViewController: self,
                                showWelcomeScreen: true
                            )
                        }
                    ),
                    Action(
                        label: "Portfolio",
                        action: {
                            TradeItSDK.launcher.launchPortfolio(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "Trading",
                        action: {
                            TradeItSDK.launcher.launchTrading(fromViewController: self, withOrder: TradeItOrder())
                        }
                    ),
                    Action(
                        label: "FX Trading",
                        action: {
                            TradeItSDK.launcher.launchFxTrading(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "Manage accounts",
                        action: {
                            TradeItSDK.launcher.launchAccountManagement(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "Broker center",
                        action: {
                            TradeItSDK.launcher.launchBrokerCenter(fromViewController: self)
                        }
                    )
                ]
            ),
            Section(
                label: "Themes",
                actions: [
                    Action(
                        label: "Light theme",
                        action: {
                            TradeItSDK.theme = TradeItTheme.light()
                            self.handleThemeChange()
                        }
                    ),
                    Action(
                        label: "Dark theme",
                        action: {
                            TradeItSDK.theme = TradeItTheme.dark()
                            self.handleThemeChange()
                        }
                    ),
                    Action(
                        label: "Custom theme",
                        action: {
                            let customTheme = TradeItTheme()
                            customTheme.backgroundColor = UIColor(red: 0.8275, green: 0.9176, blue: 1, alpha: 1.0)
                            customTheme.tableHeaderBackgroundColor = UIColor(red: 0.4784, green: 0.7451, blue: 1, alpha: 1.0)
                            TradeItSDK.theme = customTheme
                            self.handleThemeChange()
                        }
                    )
                ]
            ),
            Section(
                label: "Settings",
                actions: [
                    Action(
                        label: "Unlink all brokers",
                        action: self.deleteLinkedBrokers
                    ),
                    Action(
                        label: "Advanced options",
                        action: {
                            if let advancedViewController = self.storyboard?.instantiateViewController(withIdentifier: "EXAMPLE_VIEW_ADVANCED_ID") as? ExampleViewController {
                                self.advancedViewController = advancedViewController
                                advancedViewController.sections = self.advancedSections
                                self.navigationController?.pushViewController(advancedViewController, animated: true)
                            }
                        }
                    )
                ]
            )
        ]

        advancedSections = [
            Section(
                label: "TradeIt Flows",
                actions: [
                    Action(
                        label: "Portfolio",
                        action: {
                            TradeItSDK.launcher.launchPortfolio(fromViewController: self.advancedViewController)
                        }
                    ),
                    Action(
                        label: "Portfolio for first linked broker account",
                        action: {
                            guard let linkedBrokerAccount = TradeItSDK.linkedBrokerManager.linkedBrokers.first?.accounts.first else {
                                return print("=====> You must link a broker with an account first")
                            }

                            TradeItSDK.launcher.launchPortfolio(
                                fromViewController: self.advancedViewController,
                                forLinkedBrokerAccount: linkedBrokerAccount
                            )
                        }
                    ),
                    Action(
                        label: "Portfolio for account #",
                        action: {
                            // SINGLE-ACCT-0001 is the account number of the Dummy login
                            TradeItSDK.launcher.launchPortfolio(fromViewController: self.advancedViewController, forAccountNumber: "SINGLE-ACCT-0001")
                        }
                    ),
                    Action(
                        label: "Orders for first linked broker account",
                        action: {
                            guard let linkedBrokerAccount = TradeItSDK.linkedBrokerManager.linkedBrokers.first?.accounts.first else {
                                return print("=====> You must link a broker with an account first")
                            }
                            
                            TradeItSDK.launcher.launchOrders(
                                fromViewController: self.advancedViewController,
                                forLinkedBrokerAccount: linkedBrokerAccount
                            )
                        }
                    ),
                    Action(
                        label: "Transactions for first linked broker account",
                        action: {
                            guard let linkedBrokerAccount = TradeItSDK.linkedBrokerManager.linkedBrokers.first?.accounts.first else {
                                return print("=====> You must link a broker with an account first")
                            }

                            TradeItSDK.launcher.launchTransactions(
                                fromViewController: self.advancedViewController,
                                forLinkedBrokerAccount: linkedBrokerAccount
                            )
                    }
                    ),
                    Action(
                        label: "Trading",
                        action: {
                            TradeItSDK.launcher.launchTrading(fromViewController: self.advancedViewController, withOrder: TradeItOrder())
                        }
                    ),
                    Action(
                        label: "Trading with symbol",
                        action: {
                            let order = TradeItOrder()
                            // Any order fields that are set will pre-populate the ticket.
                            order.symbol = "CMG"
                            order.quantity = 10
                            order.action = .sell
                            order.type = .stopLimit
                            order.limitPrice = 20
                            order.stopPrice = 30
                            order.expiration = .goodUntilCanceled
                            TradeItSDK.launcher.launchTrading(fromViewController: self, withOrder: order)
                        }
                    ),
                    Action(
                        label: "Manage Accounts",
                        action: {
                            TradeItSDK.launcher.launchAccountManagement(fromViewController: self.advancedViewController)
                        }
                    ),
                    Action(
                        label: "Link a broker",
                        action: {
                            TradeItSDK.launcher.launchBrokerLinking(fromViewController: self.advancedViewController)
                        }
                    ),
                    Action(
                        label: "Relink first broker",
                        action: {
                            guard let linkedBroker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else {
                                return print("=====> ExampleApp: No brokers to relink.")
                            }

                            TradeItSDK.launcher.launchRelinking(
                                fromViewController: self.advancedViewController,
                                forLinkedBroker: linkedBroker
                            )
                        }
                    ),
                    Action(
                        label: "Broker Center",
                        action: {
                            TradeItSDK.launcher.launchBrokerCenter(fromViewController: self.advancedViewController)
                        }
                    ),
                    Action(
                        label: "Account Selection",
                        action: {
                            TradeItSDK.launcher.launchAccountSelection(
                                fromViewController: self.advancedViewController,
                                title: "Customizable instruction text",
                                onSelected: { selectedLinkedBrokerAccount in
                                    print("=====> Selected linked broker account: \(selectedLinkedBrokerAccount)")

                                    self.alertManager.showAlertWithMessageOnly(
                                        onViewController: self.advancedViewController,
                                        withTitle: "Selected Account!",
                                        withMessage: "Selected linked broker account: \(selectedLinkedBrokerAccount)",
                                        withActionTitle: "OK"
                                    )
                                }
                            )
                        }
                    ),
                    Action(
                        label: "Alert Queue",
                        action: self.launchAlertQueue
                    ),
                    Action(
                        label: "Toggle Ads",
                        action: {
                            TradeItSDK.isAdServiceEnabled = !TradeItSDK.isAdServiceEnabled

                            TradeItSDK.adService =
                                TradeItSDK.isAdServiceEnabled ? ExampleAdService() : DefaultAdService()

                            self.alertManager.showAlertWithMessageOnly(
                                onViewController: self.advancedViewController,
                                withTitle: "Toggle Ads",
                                withMessage: "Ads are now: \(TradeItSDK.isAdServiceEnabled ? "on" : "off")",
                                withActionTitle: "OK"
                            )
                        }
                    )
                ]
            ),
            Section(
                label: "Debugging",
                actions: [
                    Action(
                        label: "Unlink all brokers",
                        action: self.deleteLinkedBrokers
                    ),
                    Action(
                        label: "test",
                        action: self.test
                    )
                ]
            ),
            Section(
                label: "Custom Integration",
                actions: [
                    Action(
                        label: "manualLaunchOAuthFlow",
                        action: {
                            self.manualLaunchOAuthFlow(forBroker: "dummy")
                    }
                    ),
                    Action(
                        label: "manualLaunchOAuthRelinkFlow",
                        action: self.manualLaunchOAuthRelinkFlow
                    ),
                    Action(
                        label: "manualAuthenticateAll",
                        action: self.manualAuthenticateAll
                    ),
                    Action(
                        label: "manualBalances",
                        action: self.manualBalances
                    ),
                    Action(
                        label: "manualPositions",
                        action: self.manualPositions
                    ),
                    Action(
                        label: "manualOrders",
                        action: self.manualOrders
                    ),
                    Action(
                        label: "manualTransactions",
                        action: self.manualTransactions
                    ),
                    Action(
                        label: "manualSyncLinkedBrokers",
                        action: self.manualSyncLinkedBrokers
                    )
                ]
            ),
            Section(
                label: "Yahoo",
                actions: [
                    YahooAction(
                        label: "OAuth Flow",
                        action: {
                            TradeItSDK.yahooLauncher.launchOAuth(fromViewController: self.advancedViewController)
                        }
                    ),
                    YahooAction(
                        label: "Relink first broker",
                        action: {
                            guard let linkedBroker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else {
                                return print("=====> ExampleApp: No brokers to relink.")
                            }

                            TradeItSDK.yahooLauncher.launchRelinking(
                                fromViewController: self.advancedViewController,
                                forLinkedBroker: linkedBroker
                            )
                        }
                    ),
                    YahooAction(
                        label: "Launch Trading - Buy",
                        action: {
                            let order = TradeItOrder()

                            order.symbol = "EDIT"
                            order.action = .buy
                            TradeItSDK.yahooLauncher.launchTrading(
                                fromViewController: self.advancedViewController,
                                withOrder: order,
                                onViewPortfolioTappedHandler: { presentedViewController, linkedBrokerAccount in
                                    print("=====> GO TO PORTFOLIO \(String(describing: linkedBrokerAccount?.accountNumber))...")
                                    presentedViewController.dismiss(animated: true)
                                }
                            )
                        }
                    ),
                    YahooAction(
                        label: "Launch Trading - Sell",
                        action: {
                            let order = TradeItOrder()

                            order.symbol = "GE"
                            order.action = .sell
                            TradeItSDK.yahooLauncher.launchTrading(
                                fromViewController: self.advancedViewController,
                                withOrder: order,
                                onViewPortfolioTappedHandler: { presentedViewController, linkedBrokerAccount in
                                    print("=====> GO TO PORTFOLIO \(String(describing: linkedBrokerAccount?.accountNumber))...")
                                    presentedViewController.dismiss(animated: true)
                                }
                            )
                        }
                    ),
                    YahooAction(
                        label: "Launch Crypto Trading - Buy",
                        action: {
                            let order = TradeItCryptoOrder()

                            order.symbol = "BTC/USD"
                            order.action = .buy
                            TradeItSDK.yahooLauncher.launchCryptoTrading(
                                fromViewController: self.advancedViewController,
                                withOrder: order,
                                onViewPortfolioTappedHandler: { presentedViewController, linkedBrokerAccount in
                                    print("=====> GO TO PORTFOLIO \(String(describing: linkedBrokerAccount?.accountNumber))...")
                                    presentedViewController.dismiss(animated: true)
                                }
                            )
                        }
                    ),
                    YahooAction(
                        label: "Launch Crypto Trading - Sell",
                        action: {
                            let order = TradeItCryptoOrder()

                            order.symbol = "BTC/USD"
                            order.action = .sell
                            TradeItSDK.yahooLauncher.launchCryptoTrading(
                                fromViewController: self.advancedViewController,
                                withOrder: order,
                                onViewPortfolioTappedHandler: { presentedViewController, linkedBrokerAccount in
                                    print("=====> GO TO PORTFOLIO \(String(describing: linkedBrokerAccount?.accountNumber))...")
                                    presentedViewController.dismiss(animated: true)
                                }
                            )
                        }
                    ),
                    YahooAction(
                        label: "Manual launchAuthentication",
                        action: {
                            guard let linkedBroker = TradeItSDK.linkedBrokerManager.linkedBrokers[safe: 0] else {
                                print("=====> NO LINKED BROKERS!")
                                return
                            }

                            TradeItSDK.yahooLauncher.launchAuthentication(
                                forLinkedBroker: linkedBroker,
                                onViewController: self.advancedViewController,
                                onCompletion: {
                                    print("=====> Manual launchAuthentication completed")
                                }
                            )
                        }
                    ),
                    YahooAction(
                        label: "Launch Orders for first linked broker account",
                        action: {
                            guard let linkedBrokerAccount = TradeItSDK.linkedBrokerManager.linkedBrokers.first?.accounts.first else {
                                return print("=====> You must link a broker with an account first")
                            }

                            TradeItSDK.yahooLauncher.launchOrders(
                                fromViewController: self.advancedViewController,
                                forLinkedBrokerAccount: linkedBrokerAccount
                            )
                        }
                    ),
                    YahooAction(
                        label: "Launch Transactions for first linked broker account",
                        action: {
                            guard let linkedBrokerAccount = TradeItSDK.linkedBrokerManager.linkedBrokers.first?.accounts.first else {
                                return print("=====> You must link a broker with an account first")
                            }

                            TradeItSDK.yahooLauncher.launchTransactions(
                                fromViewController: self.advancedViewController,
                                forLinkedBrokerAccount: linkedBrokerAccount
                            )
                        }
                    )
                ]
            )
        ]

        self.sections ??= self.defaultSections

        TradeItThemeConfigurator.configure(view: self.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        TradeItSDK.oAuthCallbackUrl = URL(string: "tradeItExampleScheme://completeOAuth")!
        TradeItSDK.linkedBrokerManager.oAuthDelegate = self
        TradeItSDK.linkedBrokerManager.printLinkedBrokers()
    }

    func oAuthFlowCompleted(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        TradeItSDK.linkedBrokerManager.printLinkedBrokers()
        self.alertManager.showAlertWithMessageOnly(
            onViewController: self,
            withTitle: "Great Success!",
            withMessage: "Linked \(linkedBroker.brokerName) via OAuth",
            withActionTitle: "OK"
        )
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections?[indexPath.section].actions[indexPath.row].action()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
        let cell = UITableViewCell()
        cell.textLabel?.text = sections?[sectionIndex].label
        TradeItThemeConfigurator.configureTableHeader(header: cell)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections?[section].actions.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }

        cell?.textLabel?.text = sections?[indexPath.section].actions[indexPath.row].label

        TradeItThemeConfigurator.configure(view: cell)
        
        return cell!
    }

    // MARK: Private

    private func test() {
        // Placeholder method for testing random throwaway code

        let nums = ["", ".", "00", "01", ".10", ".1", "1.", "1..", "1...", "1..1", ".0", "0.", "0.1", "1.0", "1e5", "1x5", "1e", "e5", "NaN"]

        for num in nums {
            let numericValue = NSDecimalNumber.init(string: num)
            print("=====> numericValue: [\(num)] -> [\(numericValue)] \(numericValue == NSDecimalNumber.notANumber)")
        }
    }

    private func manualSyncLinkedBrokers() {
        let remoteBrokersToSync = [
            LinkedBrokerData(
                userId: "2c215022213205844b7c",
                userToken: "oEK4OYY8FLfLoloQWTbHufznKI5VSjJTKRz2vj%2B%2BPf6Adpf0xyJqdF%2BpmYP0VMm%2B3mfhBdJbuFNSjtk9uVfH9EmgfY1x%2Bdqtf0K70JCCnRqUye6QRczBt%2Bl8eHydsyWCVSWwKsKP24gpNHYL9L6afA%3D%3D",
                broker: "Dummy",
                brokerLongName: "Dummy Broker",
                accounts: [],
                isLinkActivationPending: true
            ),
            LinkedBrokerData(
                userId: "6ad15022323164871cf9",
                userToken: "bA3VZKHdizvmaD%2B15pIXkBR44dqL3vhXkonPpm4NkXm9iJfc17JCj0fYAFCRIt25YdsADXPOfCWnpAqi4QZHrK8sogIvd2L418w95OVgRt0dGPJEixHDd1BVMWZ9BSYgDwDznrOXd5QYoNXMlMZWPQ%3D%3D",
                broker: "Dummy",
                brokerLongName: "Dummy Broker",
                accounts: [
                    LinkedBrokerAccountData(
                        name: "Individual Account",
                        number: "SINGLE-ACCT-0001",
                        baseCurrency: "USD",
                        userCanDisableMargin: false
                    )
                ]
            ),
            LinkedBrokerData(
                userId: "3741499971984583d2f1",
                userToken: "ecwzVqxPiTtgalvlgPQOofmaxc%2BVj1JWnl8UfTwnXlMS8lQgNJ8zevAWAR1hcflBkyJ0V%2FWCuxvQdCe1vowLOcX7Hj9vpADuQfuBppFo1faGCV7q9UEjr0J4F8OhlFhgL2SwRLRz0uD411DokfX86g%3D%3D",
                broker: "dummyFx",
                brokerLongName: "Dummy Fx Broker",
                accounts: []
            )
        ]
        TradeItSDK.linkedBrokerManager.syncLocal(
            withRemoteLinkedBrokers: remoteBrokersToSync,
            onFailure: { errorResult in
                print("=====> Failed to sync linked brokers manually: \(String(describing: errorResult.shortMessage)) - \(String(describing: errorResult.longMessages?.first))")
            },
            onFinished: {
                print("=====> MANUALLY SYNC LINKED BROKERS!")
                TradeItSDK.linkedBrokerManager.printLinkedBrokers()
            }
        )
    }

    private func manualLaunchOAuthFlow(forBroker broker: String = "dummy") {
        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupUrl(
            withBroker: broker,
            oAuthCallbackUrl: URL(string: "tradeItExampleScheme://manualCompleteOAuth")!,
            onSuccess: { url in
                self.alertManager.showAlertWithMessageOnly(
                    onViewController: self.advancedViewController,
                    withTitle: "OAuthPopupUrl for Linking \(broker)",
                    withMessage: "URL: \(url)",
                    withActionTitle: "Make it so!",
                    onAlertActionTapped: {
                        UIApplication.shared.openURL(url)
                    },
                    showCancelAction: false
                )
            },
            onFailure: { errorResult in
                self.alertManager.showError(errorResult,
                                            onViewController: self.advancedViewController)
            }
        )
    }

    private func manualLaunchOAuthRelinkFlow() {
        guard let linkedBroker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else {
            print("=====> No linked brokers to relink!")

            self.alertManager.showAlertWithMessageOnly(
                onViewController: self.advancedViewController,
                withTitle: "ERROR",
                withMessage: "No linked brokers to relink!",
                withActionTitle: "Oops!"
            )

            return
        }

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupForTokenUpdateUrl(
            forLinkedBroker: linkedBroker,
            oAuthCallbackUrl: URL(string: "tradeItExampleScheme://manualCompleteOAuth")!,
            onSuccess: { url in
                self.alertManager.showAlertWithMessageOnly(
                    onViewController: self.advancedViewController,
                    withTitle: "OAuthPopupUrl for Relinking \(linkedBroker.brokerName)",
                    withMessage: "URL: \(url)",
                    withActionTitle: "Make it so!",
                    onAlertActionTapped: {
                        UIApplication.shared.openURL(url)
                    },
                    showCancelAction: false
                )
            },
            onFailure: { errorResult in
                self.alertManager.showError(
                    errorResult,
                    onViewController: self.advancedViewController
                )
            }
        )
    }

    private func manualAuthenticateAll() {
        TradeItSDK.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self.advancedViewController,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelQuestion)
            },
            onFinished: {
                self.alertManager.showAlertWithMessageOnly(
                    onViewController: self.advancedViewController,
                    withTitle: "authenticateAll finished",
                    withMessage: "\(TradeItSDK.linkedBrokerManager.linkedBrokers.count) brokers authenticated.",
                    withActionTitle: "OK")
            }
        )
    }

    private func manualBalances() {
        guard let broker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else { return print("=====> You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("=====> Accounts list is empty. Call authenticate on the broker first.") }

        account.getAccountOverview(
            onSuccess: { balance in
                print(balance ?? "Something went wrong!")
            },
            onFailure: { errorResult in
                print(errorResult)
            }
        )
    }

    private func manualPositions() {
        guard let broker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else { return print("=====> You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("=====> Accounts list is empty. Call authenticate on the broker first.") }

        account.getPositions(
            onSuccess: { positions in
                print(
                    positions.map(
                        { position in
                            return position.position
                        }
                    )
                )
            },
            onFailure: { errorResult in
                print(errorResult)
            }
        )
    }

    private func manualOrders() {
        guard let broker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else { return print("=====> You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("=====> Accounts list is empty. Call authenticate on the broker first.") }
        
        account.getAllOrderStatus(
            onSuccess: { orders in
                print("orders: \(orders)")
        }, onFailure: { error in
            print("error: \(error)")
        })
    }
    
    private func manualTransactions() {
        guard let broker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else { return print("=====> You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("=====> Accounts list is empty. Call authenticate on the broker first.") }
        
        account.getTransactionsHistory(
            onSuccess: { transactions in
                print("transactions: \(transactions)")
        }, onFailure: { error in
            print("error: \(error)")
        })
    }

    private func launchAlertQueue() {
        self.alertManager.showAlertWithMessageOnly(
            onViewController: self.advancedViewController,
            withTitle: "Alert 1",
            withMessage: "Alert 1",
            withActionTitle: "OK",
            onAlertActionTapped: {}
        )

        let securityQuestion = TradeItSecurityQuestionResult()
        securityQuestion.securityQuestion = "Security Question"

        self.alertManager.promptUserToAnswerSecurityQuestion(
            securityQuestion, onViewController: self.advancedViewController, onAnswerSecurityQuestion: { _ in }, onCancelSecurityQuestion: {}
        )

        self.alertManager.showAlertWithMessageOnly(
            onViewController: self.advancedViewController,
            withTitle: "Alert 2",
            withMessage: "Alert 2",
            withActionTitle: "OK",
            onAlertActionTapped: {}
        )
    }

    private func deleteLinkedBrokers() -> Void {
        var brokersUnlinked = 0
        let originalBrokerCount = TradeItSDK.linkedBrokerManager.linkedBrokers.count
        print("=====> Linked Broker count before clearing: \(originalBrokerCount)")

        for linkedBroker in TradeItSDK.linkedBrokerManager.linkedBrokers {
            TradeItSDK.linkedBrokerManager.unlinkBroker(
                linkedBroker,
                onSuccess: {
                    brokersUnlinked += 1
                },
                onFailure: { errorResult in
                    print("=====> Error unlinking broker(\(linkedBroker.userId)): \(errorResult.code ?? 0 as NSNumber), \(errorResult.shortMessage ?? ""), \(errorResult.longMessages?.first ?? "")")
                }
            )
        }

        let updatedBrokerCount = TradeItSDK.linkedBrokerManager.linkedBrokers.count

        self.alertManager.showAlertWithMessageOnly(
            onViewController: self.advancedViewController ?? self,
            withTitle: "Deletion complete.",
            withMessage: "Attempted to delete \(originalBrokerCount) linked brokers. \(brokersUnlinked) attempts succeeded. \(updatedBrokerCount) linked brokers remaining.",
            withActionTitle: "OK")

        print("=====> Linked Broker count after clearing: \(updatedBrokerCount)")
    }

    private func handleThemeChange() {
        let controller = self.advancedViewController ?? self
        TradeItThemeConfigurator.configure(view: controller.view)
        self.table.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: TradeItNotification.Name.didLink, object: nil)
        NotificationCenter.default.removeObserver(self, name: TradeItNotification.Name.didUnlink, object: nil)
    }
}
