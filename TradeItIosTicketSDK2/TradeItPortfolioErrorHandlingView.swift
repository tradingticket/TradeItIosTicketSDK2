import UIKit

class TradeItPortfolioErrorHandlingView: UIControl {
    @IBOutlet weak var shortMessageLabel: UILabel!
    @IBOutlet weak var longMessageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    private var linkedBrokerInError: TradeItLinkedBroker?
    
    internal weak var delegate: TradeItPortfolioErrorHandlingViewDelegate?
    
    func populateWithLinkedBrokerError(_ linkedBrokerInError: TradeItLinkedBroker) {
        self.linkedBrokerInError = linkedBrokerInError
        self.updateMessages()
        self.updateButtonText()
    }
    
    //MARK: private
    private func updateMessages() {
        let error = self.linkedBrokerInError?.error

        self.shortMessageLabel.text = error?.shortMessage ?? ""

        let longMessages = error?.longMessages as? [String] ?? [String]()
        self.longMessageLabel.text = longMessages.joined(separator: " ")
    }
    
    private func updateButtonText() {
        var text = "Reload Account"

        if let errorCode = self.linkedBrokerInError?.error?.errorCode() {
            switch errorCode {
            case TradeItErrorCode.brokerAuthenticationError: text = "Update Login"
            case TradeItErrorCode.oauthError: text = "Relink Account"
            default: text = "Reload Account"
            }
        }

        self.actionButton.setTitle(text, for: UIControlState())
    }

    // MARK: IBActions
    @IBAction func actionButtonWasTapped(WithSender sender: UIButton) {
        guard let linkedBroker = self.linkedBrokerInError
            else { return }
        if let errorCode = linkedBroker.error?.errorCode() {
            switch errorCode {
            case .brokerAuthenticationError, .oauthError:
                self.delegate?.relinkAccountWasTapped(withLinkedBroker: linkedBroker)
            default:
                self.delegate?.reloadAccountWasTapped(withLinkedBroker: linkedBroker)
            }
        }
        else {
            self.delegate?.reloadAccountWasTapped(withLinkedBroker: linkedBroker)
        }
    }
}

protocol TradeItPortfolioErrorHandlingViewDelegate: class {
    func relinkAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker)
    func reloadAccountWasTapped(withLinkedBroker linkedBroker: TradeItLinkedBroker)
}
