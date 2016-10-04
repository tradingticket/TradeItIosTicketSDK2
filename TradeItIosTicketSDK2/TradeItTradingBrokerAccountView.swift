import TradeItIosEmsApi
import UIKit

class TradeItTradingBrokerAccountView: UIView {
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var resourceAvailabilityLabel: UILabel!
    @IBOutlet weak var resourceAvailabilityDescriptionLabel: UILabel!

    enum PresentationMode {
        case BUYING_POWER
        case SHARES_OWNED
    }

    enum ActivityIndicatorState {
        case LOADING
        case LOADED
    }

    var brokerAccount: TradeItLinkedBrokerAccount?
    var presentationMode = PresentationMode.BUYING_POWER
    var sharesOwned: NSNumber = 0

    func updatePresentationMode(presentationMode: PresentationMode) {
        self.presentationMode = presentationMode
        updateResourceAvailabilityLabels()
    }

    func updateBrokerAccount(brokerAccount: TradeItLinkedBrokerAccount) {
        self.brokerAccount = brokerAccount
        self.accountButton.setTitle(brokerAccount.getFormattedAccountName(), forState: .Normal)
        updateResourceAvailabilityLabels()
    }

    func updateSharesOwned(sharesOwned: NSNumber) {
        self.sharesOwned = sharesOwned
        updateResourceAvailabilityLabels()
    }

    private func updateResourceAvailabilityLabels() {
        switch presentationMode {
        case .BUYING_POWER:
            guard let brokerAccount = brokerAccount else { return }
            self.resourceAvailabilityLabel.text = NumberFormatter.formatCurrency(brokerAccount.balance.buyingPower)
            self.resourceAvailabilityDescriptionLabel.text = "Buying Power"
        case .SHARES_OWNED:
            self.resourceAvailabilityLabel.text = NumberFormatter.formatQuantity(sharesOwned.floatValue)
            self.resourceAvailabilityDescriptionLabel.text = "Shares Owned"
        }
    }
}
