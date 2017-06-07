import UIKit

class TradeItOAuthCompletionViewController: TradeItViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var adContainer: UIView!

    var alertManager = TradeItAlertManager()
    var linkedBroker: TradeItLinkedBroker?
    var oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser!
    var delegate: TradeItOAuthCompletionViewControllerDelegate?

    private let actionButtonTitleTextContinue = "Continue"
    private let actionButtonTitleTextTryAgain = "Try again"

    private enum LinkState {
        case linking
        case succeeded
        case pending
        case failed
    }

    private var linkState: LinkState = .linking

    public override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.oAuthCallbackUrlParser != nil, "TradeItSDK ERROR: oAuthCallbackUrl not set before loading TradeItOAuthCompletionViewController")

        guard let oAuthVerifier = self.oAuthCallbackUrlParser?.oAuthVerifier else {
            self.setFailureState(withMessage: "Could not complete broker linking. No OAuth verifier present in callback. Please try again.")
            return
        }

        self.setInitialState()

        TradeItSDK.linkedBrokerManager.completeOAuth(
            withOAuthVerifier: oAuthVerifier,
            onSuccess: { linkedBroker in
                self.linkedBroker = linkedBroker
                linkedBroker.authenticateIfNeeded(
                    onSuccess: {
                        linkedBroker.refreshAccountBalances(onFinished: {
                            self.setSuccessState(forBroker: linkedBroker.brokerName)
                        })
                        NotificationCenter.default.post(name: TradeItSDK.didLinkNotificationName, object: nil, userInfo: [
                            "linkedBroker": linkedBroker
                        ])
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

        TradeItSDK.adService.populate(adContainer: adContainer, rootViewController: self, pageType: .link, position: .bottom)
    }

    // MARK: Private

    private func setInitialState() {
        self.linkState = .linking

        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.disable()

        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true

        self.statusLabel.text = "Linking..."
        self.detailsLabel.text = ""
    }

    private func setSuccessState(forBroker broker: String) {
        self.linkState = .succeeded

        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.enable()

        self.activityIndicator.stopAnimating()

        self.statusLabel.text = "Success!"
        self.detailsLabel.text = "You have successfully linked \(broker). You can now trade with your account or view your portfolio to see up to date performance."
    }
    
    private func setPendingState(forBroker broker: String) {
        self.linkState = .pending

        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.enable()
        
        self.activityIndicator.stopAnimating()
        
        self.statusLabel.text = "Activation in Progress"
        self.detailsLabel.text = "Your \(broker) link is being activated. Check back soon (up to two business days)."
    }

    private func setFailureState(withMessage message: String) {
        self.linkState = .failed

        self.actionButton.setTitle(actionButtonTitleTextTryAgain, for: .normal)
        self.actionButton.enable()
        self.activityIndicator.stopAnimating()

        self.statusLabel.text = "Oops."
        self.detailsLabel.text = message
    }

    // MARK: IBActions

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        switch self.linkState {
        case .succeeded, .pending:
            delegate?.onContinue(
                fromOAuthCompletionViewController: self,
                oAuthCallbackUrlParser: self.oAuthCallbackUrlParser,
                linkedBroker: self.linkedBroker
            )
        case .failed:
            delegate?.onTryAgain(
                fromOAuthCompletionViewController: self,
                oAuthCallbackUrlParser: self.oAuthCallbackUrlParser,
                linkedBroker: self.linkedBroker
            )
        case .linking:
            break
        }
    }
}

protocol TradeItOAuthCompletionViewControllerDelegate {
    func onContinue(
        fromOAuthCompletionViewController viewController: TradeItOAuthCompletionViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        linkedBroker: TradeItLinkedBroker?
    )

    func onTryAgain(
        fromOAuthCompletionViewController viewController: TradeItOAuthCompletionViewController,
        oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser,
        linkedBroker: TradeItLinkedBroker?
    )
}
