import UIKit

class TradeItPreviewBrandedAccountNameCell: UITableViewCell {
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var brokerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TradeItThemeConfigurator.configure(view: self)
    }
    
    func populate(linkedBroker: TradeItLinkedBrokerAccount) {
        self.accountName.text = linkedBroker.getFormattedAccountName()
        self.brokerName.text = linkedBroker.brokerLongName
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker.brokerName,
            withSize: .small,
            onSuccess: { image in
                let imageWidth = Double(image.cgImage?.width ?? 1)
                let imageHeight = Double(image.cgImage?.height ?? 1)
                self.logoWidthConstraint.constant = CGFloat(Double(15) * imageWidth / imageHeight)
                self.logo.image = image
                self.brokerName.isHidden = true
            },
            onFailure: {
                self.logo.isHidden = true
            }
        )
    }
}
