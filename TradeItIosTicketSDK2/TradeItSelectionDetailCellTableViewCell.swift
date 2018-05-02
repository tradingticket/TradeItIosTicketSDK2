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
        linkedBroker: TradeItLinkedBroker? = nil
    ) {
        self.detailPrimaryLabel.text = detailPrimaryText
        self.detailSecondaryLabel.text = detailSecondaryText
        setBrokerNameAsTextState(altTitleText: altTitleText)
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            },
            onFailure: { }
        )
    }

    func configure(
        detailPrimaryText: String?,
        detailSecondaryText: String?,
        linkedBroker: TradeItLinkedBroker? = nil
    ) {
        self.configure(
            detailPrimaryText: detailPrimaryText,
            detailSecondaryText: detailSecondaryText,
            altTitleText: linkedBroker?.brokerLongName ?? "Unknown broker",
            linkedBroker: linkedBroker
        )
    }
}
