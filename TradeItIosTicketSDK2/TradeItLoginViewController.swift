import UIKit

class TradeItLoginViewController: UIViewController {

    var tradeItConnector: TradeItConnector!
    var tradeItSession: TradeItSession!
    var selectedBroker: [String:AnyObject] = [:]
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
        
        if let brokerName = selectedBroker["longName"] as! String! {
            self.loginLabel.text = "Login in to \(brokerName)"
            self.userNameInput.placeholder = "\(brokerName) Username"
            self.passwordInput.placeholder = "\(brokerName) Password"
        }
    }
    
    @IBAction func linkButtonClick(sender: UIButton) {
        self.activityIndicator.startAnimating()
        let brokerShortName = self.selectedBroker["shortName"] as! String!
        let tradeItAuthenticationInfo = TradeItAuthenticationInfo(id: self.userNameInput.text, andPassword: self.passwordInput.text, andBroker: brokerShortName)
        
        tradeItConnector.linkBrokerWithAuthenticationInfo(tradeItAuthenticationInfo, andCompletionBlock: { (tradeItResult: TradeItResult?) in
            if let tradeItResult = tradeItResult as? TradeItErrorResult {
                let alert = UIAlertController(title: tradeItResult.shortMessage, message: (tradeItResult.longMessages as! [String]).joinWithSeparator(" "), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else if let tradeItResult = tradeItResult as? TradeItAuthLinkResult {
                self.tradeItConnector.saveLinkToKeychain(tradeItResult, withBroker: brokerShortName)
//                self.tradeItSession.authenticate(<#T##linkedLogin: TradeItLinkedLogin!##TradeItLinkedLogin!#>, withCompletionBlock: <#T##((TradeItResult!) -> Void)!##((TradeItResult!) -> Void)!##(TradeItResult!) -> Void#>)
                self.performSegueWithIdentifier(self.segueAccountsViewControllerId, sender: self)
            }
            self.activityIndicator.stopAnimating()
        })
    }
    
    @IBAction func userNameOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
    }
   
    @IBAction func passwordOnEditingChanged(sender: UITextField) {
        self.processLinkButtonEnability()
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
