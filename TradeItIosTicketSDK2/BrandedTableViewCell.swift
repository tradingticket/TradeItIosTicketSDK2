import UIKit

class BrandedTableViewCell: UITableViewCell {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var brokerName: UILabel!

    var adjustedLogoHeight: Double { return 14.0 }

    func setBrokerNameAsTextState(brokerName: String?) {
        self.brokerName.text = brokerName ?? "Unknown Broker"

        self.logo.isHidden = true
        self.brokerName?.isHidden = false
    }

    func setBrokerNameAsLogoState(logo: UIImage) {
        let newWidth = calculateAdjustedImageWidth(forImage: logo, andHeight: adjustedLogoHeight)
        self.logoWidthConstraint.constant = CGFloat(newWidth)
        self.logo.image = logo

        self.logo.isHidden = false
        self.brokerName.isHidden = true
    }

    private func calculateAdjustedImageWidth(forImage image: UIImage, andHeight height: Double) -> Double {
        let imageWidth = Double(image.cgImage?.width ?? 1)
        let imageHeight = Double(image.cgImage?.height ?? 1)
        let aspectRatio = imageWidth / imageHeight

        return adjustedLogoHeight * aspectRatio
    }
}
