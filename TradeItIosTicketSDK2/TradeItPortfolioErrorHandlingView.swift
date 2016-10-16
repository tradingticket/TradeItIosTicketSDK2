import UIKit

class TradeItPortfolioErrorHandlingView: UIControl {
    @IBOutlet weak var shortMessageLabel: UILabel!
    @IBOutlet weak var longMessageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    private var linkedBrokerInError: TradeItLinkedBroker?
    
    var delegate: TradeItPortfolioErrorHandlingViewDelegate?
    
    func populateWithLinkedBrokerError(linkedBrokerInError: TradeItLinkedBroker) {
        self.linkedBrokerInError = linkedBrokerInError
        self.updateMessages()
        self.updateButtonText()
    }
    
    //MARK: private
    private func updateMessages() {
        let error = self.linkedBrokerInError?.error

        self.shortMessageLabel.text = error?.shortMessage ?? ""

        let longMessages = error?.longMessages as? [String] ?? [String]()
        self.longMessageLabel.text = longMessages.joinWithSeparator(" ")
    }
    
    private func updateButtonText() {
        var text = "Reload Account"

        if let errorCode = self.linkedBrokerInError?.error?.errorCode() {
            switch errorCode {
            case TradeItErrorCode.BROKER_AUTHENTICATION_ERROR: text = "Update Login"
            case TradeItErrorCode.OAUTH_ERROR: text = "Relink Account"
            default: text = "Reload Account"
            }
        }

        self.actionButton.setTitle(text, forState: .Normal)
    }

    // MARK: IBActions
    @IBAction func actionButtonWasTapped(WithSender sender: UIButton) {
        if let linkedBroker = self.linkedBrokerInError, let errorCode = linkedBroker.error?.errorCode() {
            switch errorCode {
            case .BROKER_AUTHENTICATION_ERROR, .OAUTH_ERROR:
                self.delegate?.relinkAccountWasTapped(withLinkedBroker: linkedBroker)
            default:
                self.delegate?.reloadAccountWasTapped(withLinkedBroker: linkedBroker)
            }
        }
    }
}

protocol TradeItPortfolioErrorHandlingViewDelegate: class {
    func relinkAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker)
    func reloadAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker)
}
