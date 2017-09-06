import UIKit

@objc class TradeItYahooOAuthCompletionViewController: TradeItYahooViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var activityIndicatorContainer: UIView!

    let alertManager = TradeItAlertManager(linkBrokerUIFlow: TradeItYahooLinkBrokerUIFlow())
    var linkedBroker: TradeItLinkedBroker?
    var oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser!
    var delegate: TradeItYahooOAuthCompletionViewControllerDelegate?

    private let actionButtonTitleTextContinue = "Continue"
    private let actionButtonTitleTextTryAgain = "Try again"

    enum LinkState {
        case linking
        case succeeded
        case pending
        case failed
    }

    private var linkState: LinkState = .linking

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.oAuthCallbackUrlParser != nil, "TradeItSDK ERROR: oAuthCallbackUrl not set before loading TradeItOAuthCompletionViewController")

        guard let _ = self.oAuthCallbackUrlParser?.oAuthVerifier else {
            self.setFailureState(withMessage: "Could not complete broker linking. No OAuth verifier present in callback. Please try again.")
            return
        }

        self.setInitialState()

        TradeItSDK.linkedBrokerManager.completeOAuth(
            withOAuthVerifier: self.oAuthCallbackUrlParser.oAuthCallbackUrl.absoluteString, // Y! Finance backend will parse out OAuthVerifier
            onSuccess: { linkedBroker in
                self.linkedBroker = linkedBroker
                linkedBroker.authenticateIfNeeded(
                    onSuccess: {
                        linkedBroker.refreshAccountBalances(
                            onFinished: {
                                self.setSuccessState(forBroker: linkedBroker.brokerName)
                            }
                        )

                        NotificationCenter.default.post(
                            name: TradeItNotification.Name.didLink,
                            object: nil,
                            userInfo: [
                                "linkedBroker": linkedBroker
                            ]
                        )
                    },
                    onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                        self.alertManager.promptUserToAnswerSecurityQuestion(
                            securityQuestion,
                            onViewController: self,
                            onAnswerSecurityQuestion: answerSecurityQuestion,
                            onCancelSecurityQuestion: cancelSecurityQuestion
                        )
                    },
                    onFailure: { errorResult in
                        if errorResult.isAccountLinkDelayedError() { // case IB linked account not available yet, don't show alert error
                            self.setPendingState(forBroker: linkedBroker.brokerName)
                        } else {
                            self.alertManager.showError(
                                errorResult,
                                onViewController: self,
                                onFinished : {
                                    if errorResult.requiresRelink() {
                                        self.setFailureState(withMessage: "Could not complete broker linking. Please try again.")
                                    } else {
                                        self.setSuccessState(forBroker: linkedBroker.brokerName)
                                    }
                                }
                            )
                        }
                    }
                )
            },
            onFailure: { errorResult in
                print("TradeItSDK ERROR: OAuth failed with code: \(String(describing: errorResult.errorCode)), message: \(String(describing: errorResult.shortMessage)) - \(String(describing: errorResult.longMessages?.first))")
                self.alertManager.showError(errorResult, onViewController: self)

                self.setFailureState(withMessage: "Could not complete broker linking. Please try again.")
            }
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fireViewEventNotification(view: .linkCompletion, title: self.title)
    }

    // MARK: Private

    private func setInitialState() {
        self.linkState = .linking

        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.disable()

        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.activityIndicatorContainer.frame.size)
        let activityIndicator = TradeItSDK.activityViewFactory.build(frame: frame)
        self.activityIndicatorContainer.addSubview(activityIndicator)

        self.activityIndicatorContainer.isHidden = false

        self.statusLabel.text = "Linking..."
        self.detailsLabel.text = ""
    }

    private func setSuccessState(forBroker broker: String) {
        self.linkState = .succeeded

        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.enable()

        self.activityIndicatorContainer.isHidden = true

        self.statusLabel.text = "Success!"
        self.detailsLabel.text = "You have linked your \(broker) account. You can now trade from your account or view your portfolio to see up to date performance and relevant news."
    }

    private func setPendingState(forBroker broker: String) {
        self.linkState = .pending

        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.enable()

        self.activityIndicatorContainer.isHidden = true

        self.statusLabel.text = "Success!"
        self.detailsLabel.text = "You have linked your \(broker) account."
    }

    private func setFailureState(withMessage message: String) {
        self.linkState = .failed
        self.actionButton.setTitle(actionButtonTitleTextTryAgain, for: .normal)
        self.actionButton.enable()

        self.activityIndicatorContainer.isHidden = true

        self.statusLabel.text = "Oops."
        self.detailsLabel.text = message
    }

    // MARK: IBActions

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        switch self.linkState {
        case .succeeded, .pending:
            self.fireButtonTapEventNotification(button: .linkSucceeded)
            self.delegate?.onContinue(
                fromOAuthCompletionViewController: self,
                oAuthCallbackUrlParser: self.oAuthCallbackUrlParser,
                linkedBroker: self.linkedBroker
            )
        case .failed:
            self.fireButtonTapEventNotification(button: .linkFailed)
            self.delegate?.onTryAgain(
                fromOAuthCompletionViewController: self,
                oAuthCallbackUrlParser: self.oAuthCallbackUrlParser,
                linkedBroker: self.linkedBroker
            )
        case .linking:
            break
        }
    }
}

protocol TradeItYahooOAuthCompletionViewControllerDelegate {
    func onContinue(
        fromOAuthCompletionViewController viewController: TradeItYahooOAuthCompletionViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        linkedBroker: TradeItLinkedBroker?
    )

    func onTryAgain(
        fromOAuthCompletionViewController viewController: TradeItYahooOAuthCompletionViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        linkedBroker: TradeItLinkedBroker?
    )
}
