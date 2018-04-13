import UIKit

class TradeItSelectionDetailCellTableViewCell: UITableViewCell {
    @IBOutlet weak var detailPrimaryLabel: UILabel!
    @IBOutlet weak var detailSecondaryLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var brokerNameTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryView = DisclosureIndicator()
    }

    func configure(detailPrimaryText: String?, detailSecondaryText: String?, linkedBroker: TradeItLinkedBroker? = nil) {
        self.detailPrimaryLabel.text = detailPrimaryText
        self.detailSecondaryLabel.text = detailSecondaryText
        setBrokerNameAsTextState()
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            }, onFailure: { }
        )
    }
    
    private func setBrokerNameAsTextState() {
        self.logo.isHidden = true
        self.brokerNameTextLabel?.isHidden = false
    }
    
    private func setBrokerNameAsLogoState(logo: UIImage) {
        let imageWidth = Double(logo.cgImage?.width ?? 1)
        let imageHeight = Double(logo.cgImage?.height ?? 1)
        self.logoWidthConstraint.constant = CGFloat(Double(15) * imageWidth / imageHeight)
        self.logo.image = logo
        
        self.logo.isHidden = false
        self.brokerNameTextLabel?.isHidden = true
    }
}
