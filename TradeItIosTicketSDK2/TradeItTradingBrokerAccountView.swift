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

    var presentationMode = PresentationMode.buyingPower
    var sharesOwned: NSNumber = 0
    var buyingPower = ""
    var holdingType : String?

    func updatePresentationMode(_ presentationMode: PresentationMode) {
        self.presentationMode = presentationMode
        updateResourceAvailabilityLabels()
    }

    func updateBrokerAccount(_ brokerAccount: TradeItLinkedBrokerAccount) {
        self.accountButton.setTitle(brokerAccount.getFormattedAccountName(), for: UIControlState())
        updateResourceAvailabilityLabels()
    }

    func updateBuyingPower(_ buyingPower: String) {
        self.buyingPower = buyingPower
        updateResourceAvailabilityLabels()
    }

    func updatePosition(_ position: TradeItPortfolioPosition?) {
        if let position = position {
            let presenter = TradeItPortfolioPositionPresenterFactory.forTradeItPortfolioPosition(position)

            self.sharesOwned = presenter.getQuantity() ?? 0
            self.holdingType = presenter.getHoldingType()
        } else {
            self.sharesOwned = 0
            self.holdingType = nil
        }

        updateResourceAvailabilityLabels()
    }

    private func updateResourceAvailabilityLabels() {
        switch presentationMode {
        case .buyingPower:
            self.resourceAvailabilityLabel.text = self.buyingPower
            self.resourceAvailabilityDescriptionLabel.text = "Buying Power"
        case .sharesOwned:
            self.resourceAvailabilityLabel.text = NumberFormatter.formatQuantity(sharesOwned)

            if let holdingType = self.holdingType {
                self.resourceAvailabilityDescriptionLabel.text = holdingType.caseInsensitiveCompare("LONG") == .orderedSame ? "Shares Owned" : "Shares Shorted"
            } else if sharesOwned == 0 {
                self.resourceAvailabilityDescriptionLabel.text = "Shares Owned"
            } else {
                self.resourceAvailabilityDescriptionLabel.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
            }
        }
    }
}
