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
        setBrokerNameAsTextState(brokerName: linkedBroker.brokerLongName ?? "Account")
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            },
            onFailure: { }
        )
    }
    
    private func setBrokerNameAsTextState(brokerName: String) {
        self.brokerName.text = brokerName
        
        self.logo.isHidden = true
        self.brokerName?.isHidden = false
    }
    
    private func setBrokerNameAsLogoState(logo: UIImage) {
        let imageWidth = Double(logo.cgImage?.width ?? 1)
        let imageHeight = Double(logo.cgImage?.height ?? 1)
        self.logoWidthConstraint.constant = CGFloat(Double(14) * imageWidth / imageHeight)
        self.logo.image = logo
        
        self.logo.isHidden = false
        self.brokerName.isHidden = true
    }
}
