import UIKit

class TradeItTradingBrokerAccountView: UIView {
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var resourceAvailabilityLabel: UILabel!
    @IBOutlet weak var resourceAvailabilityDescriptionLabel: UILabel!

    enum PresentationMode {
        case buyingPower
        case sharesOwned
    }

    enum ActivityIndicatorState {
        case loading
        case loaded
    }

    var brokerAccount: TradeItLinkedBrokerAccount?
    var presentationMode = PresentationMode.buyingPower
    var sharesOwned: NSNumber = 0
    var holdingType : String?

    func updatePresentationMode(_ presentationMode: PresentationMode) {
        self.presentationMode = presentationMode
        updateResourceAvailabilityLabels()
    }

    func updateBrokerAccount(_ brokerAccount: TradeItLinkedBrokerAccount) {
        self.brokerAccount = brokerAccount
        self.accountButton.setTitle(brokerAccount.getFormattedAccountName(), for: UIControlState())
        updateResourceAvailabilityLabels()
    }

    func updateSharesOwned(_ presenter: TradeItPortfolioPositionPresenter) {
        self.sharesOwned = presenter.getQuantity() ?? 0
        self.holdingType = presenter.getHoldingType()
        updateResourceAvailabilityLabels()
    }

    private func updateResourceAvailabilityLabels() {
        switch presentationMode {
        case .buyingPower:
            guard let brokerAccount = brokerAccount else { return }
            let presenter = TradeItPortfolioBalancePresenterFactory.forTradeItLinkedBrokerAccount(brokerAccount)
            self.resourceAvailabilityLabel.text = presenter.getFormattedBuyingPower()
            self.resourceAvailabilityDescriptionLabel.text = "Buying Power"
        case .sharesOwned:
            self.resourceAvailabilityLabel.text = NumberFormatter.formatQuantity(sharesOwned)
            if let holdingType = self.holdingType {
                self.resourceAvailabilityDescriptionLabel.text = holdingType.caseInsensitiveCompare("LONG") == .orderedSame ? "Shares Owned" : "Shares Shorted"
            }
            else {
                self.resourceAvailabilityDescriptionLabel.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
            }
        }
    }
}
