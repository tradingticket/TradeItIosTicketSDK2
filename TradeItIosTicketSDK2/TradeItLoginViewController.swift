import UIKit

class TradeItLoginViewController: UIViewController {

    var selectedBroker: [String:AnyObject] = [:]
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var linkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let brokerName = selectedBroker["longName"] as! String! {
            loginLabel.text = "Login in to \(brokerName)"
            userNameInput.placeholder = "\(brokerName) Username"
            passwordInput.placeholder = "\(brokerName) Password"
            
            userNameInput.becomeFirstResponder()
            
            disableLinkButton()
        }
    }
    
    @IBAction func linkButtonClick(sender: UIButton) {
        print("button clicked !")
    }
    
    @IBAction func userNameOnEditingChanged(sender: UITextField) {
        self.checkLinkButtonEnability()
    }
   
    @IBAction func passwordOnEditingChanged(sender: UITextField) {
        self.checkLinkButtonEnability()
    }
    
    private func checkLinkButtonEnability() {
        if (userNameInput.text != "" && passwordInput.text != "" && !linkButton.enabled) {
            self.enableLinkButton()
        }
        else if (userNameInput.text != "" || passwordInput.text != "" && linkButton.enabled) {
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
