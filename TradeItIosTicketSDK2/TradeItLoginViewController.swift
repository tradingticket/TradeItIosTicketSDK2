import UIKit

class TradeItLoginViewController: UIViewController {

    var tradeItConnector: TradeItConnector = TradeItLauncher.tradeItConnector
    var tradeItSession: TradeItSession!
    var selectedBroker: TradeItBroker?
    let segueAccountsViewControllerId = "SEGUE_ACCOUNT_CONTROLLER"
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tradeItSession = TradeItSession(connector: tradeItConnector)

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
            self.activityIndicator.stopAnimating()
            self.enableLinkButton()
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                self.showTradeItErrorResultAlert(tradeItErrorResult)
            } else if let tradeItResult = tradeItResult as? TradeItAuthLinkResult {
                self.tradeItConnector.saveLinkToKeychain(tradeItResult, withBroker: brokerShortName)
                // TODO: self.tradeItSession.authenticate(linkedLogin: TradeItLinkedLogin!, withCompletionBlock: ((TradeItResult!) -> Void)!)
                self.performSegueWithIdentifier(self.segueAccountsViewControllerId, sender: self)
            }
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
