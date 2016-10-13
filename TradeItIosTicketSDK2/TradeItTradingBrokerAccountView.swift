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

    func updateSharesOwned(sharesOwned: NSNumber?) {
        self.sharesOwned = sharesOwned ?? 0
        updateResourceAvailabilityLabels()
    }

    private func updateResourceAvailabilityLabels() {
        switch presentationMode {
        case .BUYING_POWER:
            guard let brokerAccount = brokerAccount else { return }
            let presenter = TradeItPortfolioBalancePresenterFactory.forTradeItLinkedBrokerAccount(brokerAccount)
            self.resourceAvailabilityLabel.text = presenter.getFormattedBuyingPower()
            self.resourceAvailabilityDescriptionLabel.text = "Buying Power"
        case .SHARES_OWNED:
            // TODO: resourceAvailabilityDescriptionLabel should be "Shares Shorted" if position.holdingType == "SHORT"
            self.resourceAvailabilityLabel.text = NumberFormatter.formatQuantity(sharesOwned.floatValue)
            self.resourceAvailabilityDescriptionLabel.text = "Shares Owned"
        }
    }
}
