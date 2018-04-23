import UIKit

class TradeItSelectionDetailCellTableViewCell: BrandedTableViewCell {
    @IBOutlet weak var detailPrimaryLabel: UILabel!
    @IBOutlet weak var detailSecondaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryView = DisclosureIndicator()
    }

    func configure(
        detailPrimaryText: String?,
        detailSecondaryText: String?,
        altTitleText: String,
        linkedBroker: TradeItLinkedBroker? = nil,
        isBrandingEnabled: Bool = true
    ) {
        self.detailPrimaryLabel.text = detailPrimaryText
        self.detailSecondaryLabel.text = detailSecondaryText
        setBrokerNameAsTextState(altTitleText: altTitleText)
        if isBrandingEnabled {
            TradeItSDK.brokerLogoService.loadLogo(
                forBrokerId: linkedBroker?.brokerName,
                withSize: .small,
                onSuccess: { image in
                    self.setBrokerNameAsLogoState(logo: image)
                },
                onFailure: { }
            )
        }
    }

    func configure(
        detailPrimaryText: String?,
        detailSecondaryText: String?,
        linkedBroker: TradeItLinkedBroker? = nil,
        isBrandingEnabled: Bool = true
    ) {
        self.configure(
            detailPrimaryText: detailPrimaryText,
            detailSecondaryText: detailSecondaryText,
            altTitleText: linkedBroker?.brokerLongName ?? "Unknown broker",
            linkedBroker: linkedBroker,
            isBrandingEnabled: isBrandingEnabled
        )
    }
}
