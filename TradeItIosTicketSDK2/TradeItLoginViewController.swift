import UIKit

class TradeItLoginViewController: KeyboardViewController {

    let linkedBrokerManager: TradeItLinkedBrokerManager = TradeItSDK.linkedBrokerManager

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var delegate: TradeItLoginViewControllerDelegate?
    var selectedBroker: TradeItBroker?
    var linkedBrokerToRelink: TradeItLinkedBroker?
    var alertManager = TradeItAlertManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameInput.becomeFirstResponder()
        self.disableLinkButton()
        self.activityIndicator.hidesWhenStopped = true

        if let brokerName = self.selectedBroker?.brokerLongName {
            self.loginLabel.text = "Log in to \(brokerName)"
            self.userNameInput.placeholder = "\(brokerName) Username"
            self.passwordInput.placeholder = "\(brokerName) Password"
        }
        
        if self.linkedBrokerToRelink != nil {
            linkButton.setTitle("Relink Broker", for: UIControlState())
        }
        else {
            linkButton.setTitle("Link Broker", for: UIControlState())
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.userNameInput {
            self.passwordInput.becomeFirstResponder()
        } else if textField == self.passwordInput {
            self.linkButton.sendActions(for: .touchUpInside)
        }

        return true
    }

    // MARK: IBActions

    @IBAction func linkButtonWasTapped(_ sender: UIButton) {
        guard let brokerShortName = self.selectedBroker?.brokerShortName else { return }

        self.activityIndicator.startAnimating()

        self.disableLinkButton()
        
        let tradeItAuthenticationInfo = TradeItAuthenticationInfo(
            id: self.userNameInput.text,
            andPassword: self.passwordInput.text,
            andBroker: brokerShortName
        )!
        
        if let linkedBrokerToRelink = self.linkedBrokerToRelink {
            self.linkedBrokerManager.relinkBroker(
                linkedBrokerToRelink,
                authInfo: tradeItAuthenticationInfo,
                onSuccess: self.authenticateBroker,
                onFailure: { error in
                    self.activityIndicator.stopAnimating()
                    self.enableLinkButton()
                    self.alertManager.showError(error, onViewController: self)
                }
            )
        } else {
            self.linkedBrokerManager.linkBroker(
                authInfo: tradeItAuthenticationInfo,
                onSuccess: self.authenticateBroker,
                onFailure: { error in
                    self.activityIndicator.stopAnimating()
                    self.enableLinkButton()
                    self.alertManager.showError(error, onViewController: self)
                }
            )
        }
    }

    @IBAction func userNameOnEditingChanged(_ sender: UITextField) {
        self.updateLinkButton()
    }

    @IBAction func passwordOnEditingChanged(_ sender: UITextField) {
        self.updateLinkButton()
    }
    
    // MARK: Private

    private func authenticateBroker(_ linkedBroker: TradeItLinkedBroker) {
        linkedBroker.authenticate(
            onSuccess: { () -> Void in
                self.delegate?.brokerLinked(fromTradeItLoginViewController: self, withLinkedBroker: linkedBroker)
                self.activityIndicator.stopAnimating()
                self.enableLinkButton()
            },
            onSecurityQuestion: { (securityQuestion: TradeItSecurityQuestionResult, answerSecurityQuestion: @escaping (String) -> Void, cancelSecurityQuestion: @escaping () -> Void) -> Void in
                self.activityIndicator.stopAnimating()
                self.enableLinkButton()
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { error in
                self.linkedBrokerManager.unlinkBroker(linkedBroker)
                self.activityIndicator.stopAnimating()
                self.enableLinkButton()
                self.alertManager.showError(error, onViewController: self)
            }
        )
    }

    private func updateLinkButton() {
        if (self.userNameInput.text != "" && self.passwordInput.text != "" && !self.linkButton.isEnabled) {
            self.enableLinkButton()
        } else if ( (self.userNameInput.text == "" || self.passwordInput.text == "") && self.linkButton.isEnabled) {
            self.disableLinkButton()
        }
    }
    
    private func disableLinkButton() {
        self.linkButton.isEnabled = false
        self.linkButton.alpha = 0.5
    }
    
    private func enableLinkButton() {
        self.linkButton.isEnabled = true
        self.linkButton.alpha = 1.0
    }
}

protocol TradeItLoginViewControllerDelegate {
    func brokerLinked(fromTradeItLoginViewController: TradeItLoginViewController, withLinkedBroker linkedBroker: TradeItLinkedBroker)
}
