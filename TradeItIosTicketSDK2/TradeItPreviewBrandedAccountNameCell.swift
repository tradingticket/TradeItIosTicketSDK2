import UIKit

class TradeItPreviewBrandedAccountNameCell: UITableViewCell {
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryView = DisclosureIndicator()
    }
    
    func populate(linkedBroker: TradeItLinkedBrokerAccount) {
        self.accountName.text = linkedBroker.getFormattedAccountName()
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.logo.image = image
        }, onFailure: {
        }
        )
    }
}
