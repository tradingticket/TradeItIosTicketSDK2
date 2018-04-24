import UIKit

class TradeItPreviewBrandedAccountNameCell: BrandedTableViewCell {
    @IBOutlet weak var accountName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TradeItThemeConfigurator.configure(view: self)
    }
    
    func populate(linkedBroker: TradeItLinkedBrokerAccount) {
        self.accountName.text = linkedBroker.getFormattedAccountName()
        setBrokerNameAsTextState(altTitleText: linkedBroker.brokerLongName ?? "Account")
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            },
            onFailure: { }
        )
    }
}
