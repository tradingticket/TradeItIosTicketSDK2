import UIKit
import TradeItIosEmsApi

class TradeItLoginViewController: KeyboardViewController {

    var linkedLoginManager: TradeItLinkedLoginManager = TradeItLauncher.linkedLoginManager

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var selectedBroker: TradeItBroker?
    let toPortfolioScreenSegueId = "TO_PORTFOLIO_SCREEN_SEGUE"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameInput.becomeFirstResponder()
        self.disableLinkButton()
        self.activityIndicator.hidesWhenStopped = true

        if let brokerName = selectedBroker?.brokerLongName {
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
        
        self.linkedLoginManager.linkBroker(authInfo: tradeItAuthenticationInfo,
                                      onSuccess: {() -> Void in
                                        self.activityIndicator.stopAnimating()
                                        self.enableLinkButton()
                                        self.performSegueWithIdentifier(self.toPortfolioScreenSegueId, sender: self)
                                      },
                                      onSecurityQuestion: { (tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String in
                                        self.activityIndicator.stopAnimating()
                                        self.enableLinkButton()
                                        print("Security question result: \(tradeItSecurityQuestionResult)")

                                        // TODO: Get answer from user...
                                        return "Some Answer"
                                      },
                                      onFailure: {(tradeItErrorResult: TradeItErrorResult) -> Void in
                                        self.activityIndicator.stopAnimating()
                                        self.enableLinkButton()
                                        self.showTradeItErrorResultAlert(tradeItErrorResult)
                                      })
    }
    
    @IBAction func userNameOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
    }
   
    @IBAction func passwordOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
    }
    
    // MARK: Private

    private func showTradeItErrorResultAlert(tradeItErrorResult: TradeItErrorResult, completion: () -> Void = {}) {
        let alertController = UIAlertController(title: tradeItErrorResult.shortMessage,
                                                message: (tradeItErrorResult.longMessages as! [String]).joinWithSeparator(" "),
                                                preferredStyle: UIAlertControllerStyle.Alert)

        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            completion()
        }

        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
