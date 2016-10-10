import UIKit
import TradeItIosEmsApi

class TradeItPortfolioErrorHandlingView: UIControl {

    @IBOutlet weak var shortMessageLabel: UILabel!
    @IBOutlet weak var longMessageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    private var linkedBrokerInError: TradeItLinkedBroker!
    
    var delegate: TradeItPortfolioErrorHandlingViewDelegate?
    
    func populateWithLinkedBrokerError(linkedBrokerInError: TradeItLinkedBroker) {
        self.linkedBrokerInError = linkedBrokerInError
        self.updateMessages()
        self.updateButtonText()
    }
    
    //MARK: private
    private func updateMessages() {
        let error = self.linkedBrokerInError.error!
        self.shortMessageLabel.text = ""
        self.longMessageLabel.text = ""
        
        if let shortMessage = error.shortMessage {
            self.shortMessageLabel.text = shortMessage
        }
        if let longMessages = error.longMessages {
            self.longMessageLabel.text = (longMessages as! [String]).joinWithSeparator(" ")
        }
    }
    
    private func updateButtonText() {
        let error = self.linkedBrokerInError.error!
        var text = "Reload Account"
        if let code = error.code {
            switch code {
            case TradeItErrorCode.BROKER_AUTHENTICATION_ERROR.rawValue: text = "Update Login"
            case TradeItErrorCode.OAUTH_ERROR.rawValue: text = "Relink Account"
            default: text = "Reload Account"
            }
        }
        
        self.actionButton.setTitle(text, forState: .Normal)
    }
    
    // MARK: IBActions
    @IBAction func actionButtonWasTapped(WithSender sender: UIButton) {
        let error = self.linkedBrokerInError.error!
        if error.code != nil && (error.code == TradeItErrorCode.BROKER_AUTHENTICATION_ERROR.rawValue || error.code == TradeItErrorCode.OAUTH_ERROR.rawValue) {
                self.delegate?.relinkAccountWasTapped(withLinkedBroker: self.linkedBrokerInError)
        }
        else {
            self.delegate?.reloadAccountWasTapped(withLinkedBroker: self.linkedBrokerInError)
        }
        
        
    }
}

protocol TradeItPortfolioErrorHandlingViewDelegate: class {
    func relinkAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker)
    func reloadAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker)
}
