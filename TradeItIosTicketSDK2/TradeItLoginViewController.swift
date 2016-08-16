import UIKit

class TradeItLoginViewController: UIViewController {
    var tradeItConnector: TradeItConnector = TradeItLauncher.tradeItConnector
    var tradeItSession: TradeItSession = TradeItSession(connector: TradeItLauncher.tradeItConnector)
    var selectedBroker: TradeItBroker?
    var accounts: [TradeItAccount] = []
    let toPortfolioScreenSegueId = "TO_PORTFOLIO_SCREEN_SEGUE"
    var linkedLogin: TradeItLinkedLogin!
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userNameInput.becomeFirstResponder()
        self.disableLinkButton()
        self.activityIndicator.hidesWhenStopped = true

        if let brokerName = selectedBroker?.brokerLongName {
            self.loginLabel.text = "Login in to \(brokerName)"
            self.userNameInput.placeholder = "\(brokerName) Username"
            self.passwordInput.placeholder = "\(brokerName) Password"
        }
    }

    // MARK: IBActions
    
    @IBAction func linkButtonWasTapped(sender: UIButton) {
        guard let brokerShortName = self.selectedBroker?.brokerShortName else { return }

        self.activityIndicator.startAnimating()

        self.disableLinkButton()
        
        let tradeItAuthenticationInfo = TradeItAuthenticationInfo(id: self.userNameInput.text,
                                                                  andPassword: self.passwordInput.text,
                                                                  andBroker: brokerShortName)
        
        self.tradeItConnector.linkBrokerWithAuthenticationInfo(tradeItAuthenticationInfo,
                                                          andCompletionBlock: { (tradeItResult: TradeItResult?) in

            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                self.activityIndicator.stopAnimating()
                self.enableLinkButton()
                self.showTradeItErrorResultAlert(tradeItErrorResult)
            } else if let tradeItResult = tradeItResult as? TradeItAuthLinkResult {
                self.linkedLogin = self.tradeItConnector.saveLinkToKeychain(tradeItResult,
                                                                           withBroker: brokerShortName)

                self.tradeItSession.authenticateAsObject(self.linkedLogin,
                                                 withCompletionBlock: { (tradeItResult: TradeItResult!) in
                    self.activityIndicator.stopAnimating()
                    self.enableLinkButton()

                    if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                        self.showTradeItErrorResultAlert(tradeItErrorResult)
                    } else if let tradeItSecurityQuestionResult = tradeItResult as? TradeItSecurityQuestionResult{
                        print("Security question result: \(tradeItSecurityQuestionResult)")
                        //TODO
                    } else if let tradeItResult = tradeItResult as? TradeItAuthenticationResult {
                        self.accounts = tradeItResult.accounts as! [TradeItAccount]
                        self.performSegueWithIdentifier(self.toPortfolioScreenSegueId, sender: self)
                    }
                })
            }
        })
    }
    
    @IBAction func userNameOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
    }
   
    @IBAction func passwordOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.toPortfolioScreenSegueId {
            if let destinationViewController = segue.destinationViewController as? TradeItPortfolioViewController {
                destinationViewController.accounts = self.accounts
                destinationViewController.tradeItSession = self.tradeItSession
                destinationViewController.linkedLogin = linkedLogin
            }
        }
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
