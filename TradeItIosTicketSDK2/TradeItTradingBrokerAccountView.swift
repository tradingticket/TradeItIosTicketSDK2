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
    var holdingType : String?

    func updatePresentationMode(presentationMode: PresentationMode) {
        self.presentationMode = presentationMode
        updateResourceAvailabilityLabels()
    }

    func updateBrokerAccount(brokerAccount: TradeItLinkedBrokerAccount) {
        self.brokerAccount = brokerAccount
        self.accountButton.setTitle(brokerAccount.getFormattedAccountName(), forState: .Normal)
        updateResourceAvailabilityLabels()
    }

    func updateSharesOwned(presenter: TradeItPortfolioPositionPresenter) {
        self.sharesOwned = presenter.getQuantity() ?? 0
        self.holdingType = presenter.getHoldingType()
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
            self.resourceAvailabilityLabel.text = NumberFormatter.formatQuantity(sharesOwned.floatValue)
            if let holdingType = self.holdingType {
                self.resourceAvailabilityDescriptionLabel.text = holdingType.caseInsensitiveCompare("LONG") == .OrderedSame ? " Shares Owned" : "Shares Shorted"
            }
            else {
                self.resourceAvailabilityDescriptionLabel.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
            }
        }
    }
}
