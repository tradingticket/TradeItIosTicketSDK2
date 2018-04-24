import UIKit

class TradeItPortfolioAccountDetailsTableViewCell: BrandedTableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!

    override internal var adjustedLogoHeight: Double { return 23.0 }

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.accountNameLabel.text = linkedBrokerAccount.getFormattedAccountName()
        setBrokerNameAsTextState(brokerName: linkedBrokerAccount.brokerLongName ?? "Account")
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBrokerAccount.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            },
            onFailure: { }
        )
        if let totalValue = linkedBrokerAccount.balance?.totalValue {
            self.totalValueLabel.text = NumberFormatter.formatCurrency(totalValue, currencyCode: linkedBrokerAccount.accountBaseCurrency)
        } else {
            self.totalValueLabel.text = nil
        }
    }
}
