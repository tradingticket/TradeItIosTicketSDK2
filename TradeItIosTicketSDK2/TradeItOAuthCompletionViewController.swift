import UIKit

class TradeItOAuthCompletionViewController: TradeItViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var brokerLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var alertManager = TradeItAlertManager()
    var linkedBroker: TradeItLinkedBroker?
    var oAuthCallbackUrlParser: TradeItOAuthCallbackUrlParser?
    var delegate: TradeItOAuthCompletionViewControllerDelegate?

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
    
    override func closeButtonTitle() -> String {
        return "Cancel"
    }

    // MARK: Private

    private func setInitialState() {
        self.disableContinueButton()

        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true

        self.statusLabel.text = "Completing linking your broker..."
        self.brokerLabel.text = ""
        self.explanationLabel.text = ""
    }

    private func setSuccessState(forBroker broker: String) {
        self.enableContinueButton()

        self.activityIndicator.stopAnimating()

        self.statusLabel.text = "You have successfully linked:"
        self.brokerLabel.text = broker.uppercased()
        self.explanationLabel.text = "You can now trade with your account or view your portfolio to see up to date performance."
    }

    private func setFailureState(withMessage message: String) {
        self.enableContinueButton()
        self.activityIndicator.stopAnimating()

        self.statusLabel.text = "Something went wrong..."
//        self.brokerLabel.size
        self.brokerLabel.text = "❗"
        self.explanationLabel.text = message
    }

    private func enableContinueButton() {
        self.continueButton.isEnabled = true
        self.continueButton.alpha = 1.0
    }

    private func disableContinueButton() {
        self.continueButton.isEnabled = false
        self.continueButton.alpha = 0.5
    }

    // MARK: IBActions

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        delegate?.continueButtonTapped(fromOAuthCompletionViewViewController: self, linkedBroker: self.linkedBroker)
    }
}

@objc protocol TradeItOAuthCompletionViewControllerDelegate {
    func continueButtonTapped(fromOAuthCompletionViewViewController viewController: TradeItOAuthCompletionViewController, linkedBroker: TradeItLinkedBroker?)
}
