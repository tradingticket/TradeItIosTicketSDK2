import UIKit
import TradeItIosEmsApi

class TradeItLoginViewController: KeyboardViewController {

    let linkedBrokerManager: TradeItLinkedBrokerManager = TradeItLauncher.linkedBrokerManager

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var delegate: TradeItLoginViewControllerDelegate?
    var selectedBroker: TradeItBroker?
    var mode: TradeItLoginViewControllerMode?
    var relinkLinkedBroker: TradeItLinkedBroker?
    var tradeItAlert = TradeItAlert()

    let toPortfolioScreenSegueId = "TO_PORTFOLIO_SCREEN_SEGUE"

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
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.userNameInput {
            self.passwordInput.becomeFirstResponder()
        } else if textField == self.passwordInput {
            self.linkButton.sendActionsForControlEvents(.TouchUpInside)
        }

        return true
    }

    // MARK: IBActions

    @IBAction func linkButtonWasTapped(sender: UIButton) {
        guard let brokerShortName = self.selectedBroker?.brokerShortName else { return }

        self.activityIndicator.startAnimating()

        self.disableLinkButton()
        
        let tradeItAuthenticationInfo = TradeItAuthenticationInfo(id: self.userNameInput.text,
                                                                  andPassword: self.passwordInput.text,
                                                                  andBroker: brokerShortName)
        
        if self.mode == TradeItLoginViewControllerMode.relink {
            self.linkedBrokerManager.relinkBroker(self.relinkLinkedBroker!,
                                                  authInfo: tradeItAuthenticationInfo,
                                                  onSuccess: { (linkedBroker: TradeItLinkedBroker) -> Void in
                                                    self.authenticateBroker(linkedBroker)
                },
                                                  onFailure: {(tradeItErrorResult: TradeItErrorResult) -> Void in
                                                    self.activityIndicator.stopAnimating()
                                                    self.enableLinkButton()
                                                    self.tradeItAlert.showTradeItErrorResultAlert(onController: self, withError: tradeItErrorResult)
            })
        }
        else {
            self.linkedBrokerManager.linkBroker(authInfo: tradeItAuthenticationInfo,
                                                onSuccess: {(linkedBroker: TradeItLinkedBroker) -> Void in
                                                    self.authenticateBroker(linkedBroker)
                },
                                                onFailure: {(tradeItErrorResult: TradeItErrorResult) -> Void in
                                                    self.activityIndicator.stopAnimating()
                                                    self.enableLinkButton()
                                                    self.tradeItAlert.showTradeItErrorResultAlert(onController: self, withError: tradeItErrorResult)
            })
        }
    }

    @IBAction func userNameOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
    }

    @IBAction func passwordOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
    }
    
    // MARK: Private

    private func authenticateBroker(linkedBroker: TradeItLinkedBroker) {
        linkedBroker.authenticate(
            onSuccess: { () -> Void in
                self.delegate?.brokerLinked(self, withLinkedBroker: linkedBroker)
                self.activityIndicator.stopAnimating()
                self.enableLinkButton()
            },
            onSecurityQuestion: { (tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String in
                self.activityIndicator.stopAnimating()
                self.enableLinkButton()
                print("Security question result: \(tradeItSecurityQuestionResult)")

                // TODO: Get answer from user...
                return "Some Answer"
            },
            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                //TODO delete linkedLogin in keychain ?
                self.activityIndicator.stopAnimating()
                self.enableLinkButton()
                self.tradeItAlert.showTradeItErrorResultAlert(onController: self, withError: tradeItErrorResult)
            }
        )
    }

    

    private func processLinkButtonEnability() {
        if (self.userNameInput.text != "" && self.passwordInput.text != "" && !self.linkButton.enabled) {
            self.enableLinkButton()
        }
        else if ( (self.userNameInput.text == "" || self.passwordInput.text == "") && self.linkButton.enabled) {
            self.disableLinkButton()
        }
    }
    
    private func disableLinkButton() {
        self.linkButton.enabled = false
        self.linkButton.alpha = 0.5
    }
    
    private func enableLinkButton() {
        self.linkButton.enabled = true
        self.linkButton.alpha = 1.0
    }
}

protocol TradeItLoginViewControllerDelegate {
    func brokerLinked(fromTradeItLoginViewController: TradeItLoginViewController, withLinkedBroker linkedBroker: TradeItLinkedBroker)
}

enum TradeItLoginViewControllerMode: String {
    case relink
}
