import UIKit
@testable import TradeItIosTicketSDK2

struct Section {
    let label: String
    let actions: [Action]
}

struct Action {
    let label: String
    let action: () -> Void
}

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TradeItOAuthDelegate {
    @IBOutlet weak var table: UITableView!

    var sections: [Section]!
    let alertManager: TradeItAlertManager = TradeItAlertManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        sections = [
            Section(
                label: "TradeIt Flows",
                actions: [
                    Action(
                        label: "launchPortfolio",
                        action: {
                            TradeItSDK.launcher.launchPortfolio(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "launchPortfolioForLinkedBrokerAccount",
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
                        label: "launchPortfolioForAccountNumber",
                        action: {
                            // brkAcct1 is the account number of the Dummy login
                            TradeItSDK.launcher.launchPortfolio(fromViewController: self, forAccountNumber: "brkAcct1")
                        }
                    ),
                    Action(
                        label: "launchTrading",
                        action: {
                            TradeItSDK.launcher.launchTrading(fromViewController: self, withOrder: TradeItOrder())
                        }
                    ),
                    Action(
                        label: "launchTradingWithSymbol",
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
                        label: "launchAccountManagement",
                        action: {
                            TradeItSDK.launcher.launchAccountManagement(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "launchBrokerLinking",
                        action: {
                            TradeItSDK.launcher.launchBrokerLinking(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "launchBrokerCenter",
                        action: {
                            TradeItSDK.launcher.launchBrokerCenter(fromViewController: self)
                        }
                    ),
                    Action(
                        label: "launchAccountSelection",
                        action: {
                            TradeItSDK.launcher.launchAccountSelection(
                                fromViewController: self,
                                title: "Select account to sync",
                                onSelected: { selectedLinkedBrokerAccount in
                                    self.alertManager.showAlert(
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
                        label: "launchAlertQueue",
                        action: self.launchAlertQueue
                    )
                ]
            ),
            Section(
                label: "Debugging",
                actions: [
                    Action(
                        label: "deleteLinkedBrokers",
                        action: self.deleteLinkedBrokers
                    ),
                    Action(
                        label: "test",
                        action: self.test
                    )
                ]
            ),
            Section(
                label: "Debugging",
                actions: [
                    Action(
                        label: "deleteLinkedBrokers",
                        action: deleteLinkedBrokers
                    ),
                    Action(
                        label: "test",
                        action: test
                    )
                ]
            ),
            Section(
                label: "Themes",
                actions: [
                    Action(
                        label: "setLightTheme",
                        action: {
                            TradeItSDK.theme = TradeItTheme.light()
                        }
                    ),
                    Action(
                        label: "setDarkTheme",
                        action: {
                            TradeItSDK.theme = TradeItTheme.dark()
                        }
                    ),
                    Action(
                        label: "setCustomTheme",
                        action: {
                            let customTheme = TradeItTheme()
                            customTheme.textColor = UIColor.magenta
                            customTheme.backgroundColor = UIColor.green
                            TradeItSDK.theme = customTheme
                        }
                    )
                ]
            ),
            Section(
                label: "Deep Integration",
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
                    Action(
                        label: "launchOAuthFlow",
                        action: self.launchYahooOAuthFlow
                    ),
                    Action(
                        label: "Launch Trading",
                        action: {
                            let order = TradeItOrder()

                            order.symbol = "YHOO"
                            order.action = .buy
                            TradeItSDK.yahooLauncher.launchTrading(fromViewController: self, withOrder: order)
                        }
                    )
                ]
            )
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TradeItSDK.linkedBrokerManager.oAuthDelegate = self
        printLinkedBrokers()
    }

    func oAuthFlowCompleted(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.printLinkedBrokers()
        self.alertManager.showAlert(
            onViewController: self,
            withTitle: "Great Success!",
            withMessage: "Linked \(linkedBroker.brokerName) via OAuth",
            withActionTitle: "OK"
        )
    }

    func yahooOAuthFlowCompleted(withLinkedBroker linkedBroker: TradeItLinkedBroker) {
        self.printLinkedBrokers()
        self.alertManager.showAlert(
            onViewController: self,
            withTitle: "Great Success!",
            withMessage: "Yahoo: Linked \(linkedBroker.brokerName) via OAuth",
            withActionTitle: "OK",
            onAlertActionTapped: {
                TradeItSDK.yahooLauncher.launchOAuthConfirmationScreen(fromViewController: self,
                                                                       withLinkedBroker: linkedBroker)
            }
        )
    }

    // Mark: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].actions[indexPath.row].action()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].label
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].actions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }

        cell?.textLabel?.text = sections[indexPath.section].actions[indexPath.row].label
        
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

    private func launchYahooOAuthFlow() {
        TradeItSDK.yahooLauncher.launchOAuth(fromViewController: self, withCallbackUrl: URL(string: "tradeItExampleScheme://completeYahooOAuth")!)
    }

    private func manualBuildLinkedBroker() {
        TradeItSDK.linkedBrokerManager.linkedBrokers = []

        TradeItSDK.linkedBrokerManager.linkBroker(
            userId: "e041482902073625472a",
            userToken: "R4U3fyK4vjFAMCa9hRwm1qbfgaN669WGkwksirBgKulUcW5WJhqLEGPOhXJ6MsiV6hH3BTIDrkRQXlLCqBj1tEIIODef%2FiJJbMcJ49pKW%2FLlKTcCW2Ygzz%2BrFDIKlq38H8yMa6R%2B%2F0NHuYC6THvD4A%3D%3D",
            broker: "dummy",
            onSuccess: { linkedBroker in
                linkedBroker.accounts = [
                    TradeItLinkedBrokerAccount(
                        linkedBroker: linkedBroker,
                        accountName: "Manual Account Name",
                        accountNumber: "Manual Account Number",
                        balance: nil,
                        fxBalance: nil,
                        positions: [])
                ]

                print("=====> MANUALLY BUILT LINK!")
                self.printLinkedBrokers()
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelQuestion)
            },
            onFailure: { errorResult in
                print("=====> Failed to manually link: \(errorResult.shortMessage) - \(errorResult.longMessages?.first)")
            }
        )
    }

    private func manualLaunchOAuthFlow(forBroker broker: String = "dummy") {
        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupUrl(
            withBroker: broker,
            oAuthCallbackUrl: URL(string: "tradeItExampleScheme://manualCompleteOAuth")!,
            onSuccess: { url in
                self.alertManager.showAlert(
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

            self.alertManager.showAlert(
                onViewController: self,
                withTitle: "ERROR",
                withMessage: "No linked brokers to relink!",
                withActionTitle: "Oops!"
            )

            return
        }

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupForTokenUpdateUrl(
            withBroker: linkedBroker.brokerName,
            userId: linkedBroker.linkedLogin.userId ?? "",
            oAuthCallbackUrl: URL(string: "tradeItExampleScheme://manualCompleteOAuth")!,
            onSuccess: { url in
                self.alertManager.showAlert(
                    onViewController: self,
                    withTitle: "OAuthPopupUrl for Relinking \(linkedBroker.brokerName)",
                    withMessage: "URL: \(url)",
                    withActionTitle: "Make it so!",
                    onAlertActionTapped: {
                        UIApplication.shared.openURL(url)                    },
                    showCancelAction: false
                )
            },
            onFailure: { errorResult in
                self.alertManager.showError(errorResult,
                                            onViewController: self)
            }
        )
    }

    private func printLinkedBrokers() {
        print("\n\n=====> LINKED BROKERS:")

        for linkedBroker in TradeItSDK.linkedBrokerManager.linkedBrokers {
            let linkedLogin = linkedBroker.linkedLogin
            let userToken = TradeItSDK.linkedBrokerManager.connector.userToken(fromKeychainId: linkedLogin.keychainId)
            print("=====> \(linkedLogin.broker ?? "MISSING BROKER")(\(linkedBroker.accounts.count) accounts)\n    userId: \(linkedLogin.userId ?? "MISSING USER ID")\n    keychainId: \(linkedLogin.keychainId ?? "MISSING KEYCHAIN ID")\n    userToken: \(userToken ?? "MISSING USER TOKEN")")
        }

        print("=====> ===============\n\n")
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
                self.alertManager.showAlert(
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

        account.getAccountOverview(onSuccess: { balance in
            print(balance ?? "Something went wrong!")
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

    private func manualPositions() {
        guard let broker = TradeItSDK.linkedBrokerManager.linkedBrokers.first else { return print("=====> You must link a broker first.") }
        guard let account = broker.accounts.first else { return print("=====> Accounts list is empty. Call authenticate on the broker first.") }

        account.getPositions(onSuccess: { positions in
            print(positions.map({ position in
                return position.position
            }))
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

    private func launchAlertQueue() {
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

    private func deleteLinkedBrokers() -> Void {
        let originalBrokerCount = TradeItSDK.linkedBrokerManager.linkedBrokers.count
        print("=====> Keychain Linked Login count before clearing: \(originalBrokerCount)")

        let appDomain = Bundle.main.bundleIdentifier;
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)

        let connector = TradeItConnector(apiKey: AppDelegate.API_KEY)
        connector.environment = AppDelegate.ENVIRONMENT

        let linkedLogins = connector.getLinkedLogins() as! [TradeItLinkedLogin]

        for linkedLogin in linkedLogins {
            connector.unlinkLogin(linkedLogin)
        }

        TradeItSDK.linkedBrokerManager.linkedBrokers = []

        let updatedBrokerCount = TradeItSDK.linkedBrokerManager.linkedBrokers.count
        self.alertManager.showAlert(
            onViewController: self,
            withTitle: "Deletion complete.",
            withMessage: "Deleted \(originalBrokerCount) linked brokers. \(updatedBrokerCount) brokers remaining.",
            withActionTitle: "OK")

        print("=====> Keychain Linked Login count after clearing: \(updatedBrokerCount)")
    }
}
