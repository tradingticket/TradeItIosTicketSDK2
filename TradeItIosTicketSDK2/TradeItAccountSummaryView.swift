import TradeItIosEmsApi
import UIKit

class TradeItAccountSummaryView: UIView {
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var availableDescriptionLabel: UILabel!

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
        updateAvailableLabels()
    }

    func updateBrokerAccount(brokerAccount: TradeItLinkedBrokerAccount) {
        self.brokerAccount = brokerAccount
        self.accountButton.setTitle(brokerAccount.getFormattedAccountName(), forState: .Normal)
        updateAvailableLabels()
    }

    func updateSharesOwned(sharesOwned: NSNumber) {
        self.sharesOwned = sharesOwned
        updateAvailableLabels()
    }

    private func updateAvailableLabels() {
        switch presentationMode {
        case .BUYING_POWER:
            guard let brokerAccount = brokerAccount else { return }
            self.availableLabel.text = NumberFormatter.formatCurrency(brokerAccount.balance.buyingPower)
            self.availableDescriptionLabel.text = "Buying Power"
        case .SHARES_OWNED:
            self.availableLabel.text = NumberFormatter.formatQuantity(sharesOwned.floatValue)
            self.availableDescriptionLabel.text = "Shares Owned"
        }
    }
}
