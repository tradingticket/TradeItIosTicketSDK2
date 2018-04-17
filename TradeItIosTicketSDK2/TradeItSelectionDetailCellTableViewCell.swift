import UIKit

class TradeItSelectionDetailCellTableViewCell: BrandedTableViewCell {
    @IBOutlet weak var detailPrimaryLabel: UILabel!
    @IBOutlet weak var detailSecondaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryView = DisclosureIndicator()
    }

    func configure(detailPrimaryText: String?, detailSecondaryText: String?, linkedBroker: TradeItLinkedBroker? = nil) {
        self.detailPrimaryLabel.text = detailPrimaryText
        self.detailSecondaryLabel.text = detailSecondaryText
        setBrokerNameAsTextState(brokerName: linkedBroker?.brokerLongName)
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            }, onFailure: { }
        )
    }
}
