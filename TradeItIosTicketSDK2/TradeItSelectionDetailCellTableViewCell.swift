import UIKit

class TradeItSelectionDetailCellTableViewCell: UITableViewCell {
    @IBOutlet weak var detailPrimaryLabel: UILabel!
    @IBOutlet weak var detailSecondaryLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryView = DisclosureIndicator()
    }

    func configure(detailPrimaryText: String?, detailSecondaryText: String?, linkedBroker: TradeItLinkedBroker? = nil) {
        self.detailPrimaryLabel.text = detailPrimaryText
        self.detailSecondaryLabel.text = detailSecondaryText
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.logo.image = image
            }, onFailure: { 
            }
        )
    }
}
