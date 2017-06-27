import UIKit
@testable import TradeItIosTicketSDK2

struct Section {
    let label: String
    let actions: [Action]
}

class Action {
    public var label: String
    public var action: () -> Void

    init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
}

class YahooAction: Action {
    override init(label: String, action: @escaping () -> Void) {
        super.init(
            label: label,
            action: {
                TradeItSDK.oAuthCallbackUrl = URL(string: "tradeItExampleScheme://completeYahooOAuth")!
                action()
            }
        )
    }
}



class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TradeItOAuthDelegate {
    @IBOutlet weak var table: UITableView!

    internal var sections: [Section]?
    var defaultSections: [Section]!
    var advancedSections: [Section]!
    let alertManager: TradeItAlertManager = TradeItAlertManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UIImage(named: "tradeit_logo.png")
        let logoView = UIImageView(image: logo)
        self.navigationItem.titleView = logoView
        self.registerLinkObservers()

        defaultSections = [
            Section(
                label: "SDK SCREENS",
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
                label: "THEMES",
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
                label: "SETTINGS",
                actions: [
                    Action(
                        label: "Unlink all brokers",
                        action: self.deleteLinkedBrokers
                    ),
                    Action(
                        label: "Advanced options",
                        action: {
                            if let exampleViewController = self.storyboard?.instantiateViewController(withIdentifier: "EXAMPLE_VIEW_ID") as? ExampleViewController {
                                exampleViewController.sections = self.advancedSections
                                self.navigationController?.pushViewController(exampleViewController, animated: true)
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
                            TradeItSDK.launcher.launchPortfolio(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "Portfolio for linked broker account",
                        action: {
                            guard let linkedBrokerAccount = TradeItSDK.linkedBrokerManager.linkedBrokers.first?.accounts.last else {
                                return print("=====> You must link a broker with an account first")
                            }

                            TradeItSDK.launcher.launchPortfolio(
                                fromViewController: self,
                                forLinkedBrokerAccount: linkedBrokerAccount
                            )
                        }
                    ),
                    Action(
                        label: "Portfolio for account #",
                        action: {
                            // brkAcct1 is the account number of the Dummy login
                            TradeItSDK.launcher.launchPortfolio(fromViewController: self, forAccountNumber: "brkAcct1")
                        }
                    ),
                    Action(
                        label: "Trading",
                        action: {
                            TradeItSDK.launcher.launchTrading(fromViewController: self, withOrder: TradeItOrder())
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
                            TradeItSDK.launcher.launchAccountManagement(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "Link a broker",
                        action: {
                            TradeItSDK.launcher.launchBrokerLinking(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "Broker Center",
                        action: {
                            TradeItSDK.launcher.launchBrokerCenter(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "Account Selection",
                        action: {
                            TradeItSDK.launcher.launchAccountSelection(
                                fromViewController: self,
                                title: "Customizable instruction text",
                                onSelected: { selectedLinkedBrokerAccount in
                                    print("=====> Selected linked broker account: \(selectedLinkedBrokerAccount)")

                                    self.alertManager.showAlertWithMessageOnly(
                                        onViewController: self,
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
                label: "THEMES",
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
                        label: "manualBuildLinkedBroker",
                        action: self.manualBuildLinkedBroker
                    )
                ]
            ),
            Section(
                label: "Yahoo",
                actions: [
                    YahooAction(
                        label: "OAuth Flow",
                        action: {
                            TradeItSDK.yahooLauncher.launchOAuth(fromViewController: self)
                        }
                    ),
                    YahooAction(
                        label: "Launch Trading - Buy",
                        action: {
                            let order = TradeItOrder()

                            order.symbol = "YHOO"
                            order.action = .buy
                            TradeItSDK.yahooLauncher.launchTrading(
                                fromViewController: self,
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
                                fromViewController: self,
                                withOrder: order,
                                onViewPortfolioTappedHandler: { presentedViewController, linkedBrokerAccount in
                                    print("=====> GO TO PORTFOLIO \(String(describing: linkedBrokerAccount?.accountNumber))...")
                                    presentedViewController.dismiss(animated: true)
                                }
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

    // Mark: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections?[indexPath.section].actions[indexPath.row].action()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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

    private func manualBuildLinkedBroker() {
        TradeItSDK.linkedBrokerManager.linkedBrokers = []

        TradeItSDK.linkedBrokerManager.injectBroker(
            userId: "e041482902073625472a",
            userToken: "R4U3fyK4vjFAMCa9hRwm1qbfgaN669WGkwksirBgKulUcW5WJhqLEGPOhXJ6MsiV6hH3BTIDrkRQXlLCqBj1tEIIODef%2FiJJbMcJ49pKW%2FLlKTcCW2Ygzz%2BrFDIKlq38H8yMa6R%2B%2F0NHuYC6THvD4A%3D%3D",
            broker: "dummy",
            onSuccess: { linkedBroker in
                linkedBroker.authenticateIfNeeded(onSuccess: {
                    linkedBroker.accounts = [
                        TradeItLinkedBrokerAccount(
                            linkedBroker: linkedBroker,
                            accountName: "Manual Account Name",
                            accountNumber: "Manual Account Number",
                            accountBaseCurrency: "USD",
                            balance: nil,
                            fxBalance: nil,
                            positions: [],
                            orderCapabilities: []
                        )
                    ]

                    print("=====> MANUALLY BUILT LINK!")
                    TradeItSDK.linkedBrokerManager.printLinkedBrokers()
                }, onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
                    self.alertManager.promptUserToAnswerSecurityQuestion(
                        securityQuestion,
                        onViewController: self,
                        onAnswerSecurityQuestion: answerSecurityQuestion,
                        onCancelSecurityQuestion: cancelQuestion)
                }, onFailure: { errorResult in
                    print("=====> Failed to authenticate manual link: \(String(describing: errorResult.shortMessage)) - \(String(describing: errorResult.longMessages?.first))")
                })
            },
            onFailure: { errorResult in
                print("=====> Failed to manually link: \(String(describing: errorResult.shortMessage)) - \(String(describing: errorResult.longMessages?.first))")
            }
        )
    }

    private func manualLaunchOAuthFlow(forBroker broker: String = "dummy") {
        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupUrl(
            withBroker: broker,
            oAuthCallbackUrl: URL(string: "tradeItExampleScheme://manualCompleteOAuth")!,
            onSuccess: { url in
                self.alertManager.showAlertWithMessageOnly(
                    onViewController: self,
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
                                            onViewController: self)
            }
        )
    }

    private func manualLaunchOAuthRelinkFlow() {
        guard let linkedBroker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else {
            print("=====> No linked brokers to relink!")

            self.alertManager.showAlertWithMessageOnly(
                onViewController: self,
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
                    onViewController: self,
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
                    onViewController: self
                )
            }
        )
    }

    private func manualAuthenticateAll() {
        TradeItSDK.linkedBrokerManager.authenticateAll(
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelQuestion)
            },
            onFinished: {
                self.alertManager.showAlertWithMessageOnly(
                    onViewController: self,
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

    private func launchAlertQueue() {
        self.alertManager.showAlertWithMessageOnly(
            onViewController: self,
            withTitle: "Alert 1",
            withMessage: "Alert 1",
            withActionTitle: "OK",
            onAlertActionTapped: {}
        )

        let securityQuestion = TradeItSecurityQuestionResult()
        securityQuestion.securityQuestion = "Security Question"

        self.alertManager.promptUserToAnswerSecurityQuestion(
            securityQuestion, onViewController: self, onAnswerSecurityQuestion: { _ in }, onCancelSecurityQuestion: {}
        )

        self.alertManager.showAlertWithMessageOnly(
            onViewController: self,
            withTitle: "Alert 2",
            withMessage: "Alert 2",
            withActionTitle: "OK",
            onAlertActionTapped: {}
        )
    }

    private func deleteLinkedBrokers() -> Void {
        let originalBrokerCount = TradeItSDK.linkedBrokerManager.linkedBrokers.count
        print("=====> Keychain Linked Login count before clearing: \(originalBrokerCount)")

        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)

        let connector = TradeItConnector(apiKey: AppDelegate.API_KEY)
        connector.environment = AppDelegate.ENVIRONMENT

        let linkedLogins = connector.getLinkedLogins() as! [TradeItLinkedLogin]

        for linkedLogin in linkedLogins {
            connector.unlinkLogin(linkedLogin)
            if let linkedBroker = TradeItSDK.linkedBrokerManager.linkedBrokers.filter({ $0.linkedLogin.userId == linkedLogin.userId }).first {
                TradeItSDK.linkedBrokerCache.remove(linkedBroker: linkedBroker)
            }
        }

        TradeItSDK.linkedBrokerManager.linkedBrokers = []

        let updatedBrokerCount = TradeItSDK.linkedBrokerManager.linkedBrokers.count
        self.alertManager.showAlertWithMessageOnly(
            onViewController: self,
            withTitle: "Deletion complete.",
            withMessage: "Deleted \(originalBrokerCount) linked brokers. \(updatedBrokerCount) brokers remaining.",
            withActionTitle: "OK")

        print("=====> Keychain Linked Login count after clearing: \(updatedBrokerCount)")
    }

    private func handleThemeChange() {
        TradeItThemeConfigurator.configure(view: self.view)
        self.table.reloadData()
    }

    private func registerLinkObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didLink), name: TradeItSDK.didLinkNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnlink), name: TradeItSDK.didUnlinkNotificationName, object: nil)
    }

    func didLink(notification: Notification) {
        print("TradeItSDK: didLink notification")
        guard let linkedBroker = notification.userInfo?["linkedBroker"] as? TradeItLinkedBroker else {
            return print("No linkedBroker passed with notification")
        }
        print(linkedBroker.brokerName)
    }

    func didUnlink(notification: Notification) {
        print("TradeItSDK: didUnlink notification")
        guard let linkedBroker = notification.userInfo?["linkedBroker"] as? TradeItLinkedBroker else {
            return print("No linkedBroker passed with notification")
        }
        print(linkedBroker.brokerName)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: TradeItSDK.didLinkNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: TradeItSDK.didUnlinkNotificationName, object: nil)
    }
}
