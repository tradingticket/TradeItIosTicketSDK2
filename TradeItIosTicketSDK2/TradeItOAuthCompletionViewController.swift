import UIKit

class TradeItOAuthCompletionViewController: TradeItViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var alertManager = TradeItAlertManager()
    var linkedBroker: TradeItLinkedBroker?
    var oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser?
    var delegate: TradeItOAuthCompletionViewControllerDelegate?

    private let actionButtonTitleTextContinue = "Continue"
    private let actionButtonTitleTextTryAgain = "Try again"

    override func viewDidLoad() {
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
                        self.setSuccessState(forBroker: linkedBroker.brokerName)
                    },
                    onSecurityQuestion: { (securityQuestion, answerSecurityQuestion, cancelSecurityQuestion) in
                        self.alertManager.promptUserToAnswerSecurityQuestion(
                            securityQuestion,
                            onViewController: self,
                            onAnswerSecurityQuestion: answerSecurityQuestion,
                            onCancelSecurityQuestion: cancelSecurityQuestion
                        )
                    },
                    onFailure: { errorResult in
                        self.alertManager.showRelinkError(
                            errorResult,
                            withLinkedBroker: linkedBroker,
                            onViewController: self,
                            onFinished : {
                                self.setSuccessState(forBroker: linkedBroker.brokerName)
                            }
                        )
                    }
                )
            },
            onFailure: { errorResult in
                print("TradeItSDK ERROR: OAuth failed with code: \(errorResult.errorCode), message: \(errorResult.shortMessage) - \(errorResult.longMessages?.first)")
                self.alertManager.showError(errorResult, onViewController: self)

                self.setFailureState(withMessage: "Could not complete broker linking. Please try again.")
            }
        )
    }

    // MARK: Private

    private func setInitialState() {
        self.view.backgroundColor = UIColor.tradeItlightGreyBackgroundColor

        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.disable()

        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true

        self.statusLabel.text = "Linking..."
        self.statusLabel.textColor = UIColor.tradeItCoolBlueColor()
        self.detailsLabel.text = ""
    }

    private func setSuccessState(forBroker broker: String) {
        self.actionButton.setTitle(actionButtonTitleTextContinue, for: .normal)
        self.actionButton.enable()

        self.activityIndicator.stopAnimating()

        self.statusLabel.text = "Success"
        self.detailsLabel.text = "You have successfully linked \(broker). You can now trade with your account or view your portfolio to see up to date performance."
    }

    private func setFailureState(withMessage message: String) {
        self.actionButton.setTitle(actionButtonTitleTextTryAgain, for: .normal)
        self.actionButton.enable()
        self.activityIndicator.stopAnimating()

        self.statusLabel.text = "Oops"
        self.detailsLabel.text = message
    }

    // MARK: IBActions

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if self.actionButton.title(for: .normal) == actionButtonTitleTextContinue {
            delegate?.onContinue(fromOAuthCompletionViewViewController: self, linkedBroker: self.linkedBroker)
        } else if self.actionButton.title(for: .normal) == actionButtonTitleTextTryAgain {
            delegate?.onTryAgain(fromOAuthCompletionViewViewController: self)
        }
    }
}

@objc protocol TradeItOAuthCompletionViewControllerDelegate {
    func onContinue(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController,
                    linkedBroker: TradeItLinkedBroker?)

    func onTryAgain(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController)
}
