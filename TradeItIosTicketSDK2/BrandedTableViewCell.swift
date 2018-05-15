import UIKit

class BrandedTableViewCell: UITableViewCell {
    @IBOutlet weak var logoTitle: UIImageView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var altTitle: UILabel!

    var adjustedLogoHeight: Double { return 14.0 }

    func setBrokerNameAsTextState(altTitleText: String) {
        self.altTitle.text = altTitleText

        self.logoTitle.isHidden = true
        self.altTitle?.isHidden = false
    }

    func setBrokerNameAsLogoState(logo: UIImage) {
        let newWidth = calculateAdjustedImageWidth(forImage: logo, andHeight: adjustedLogoHeight)
        self.logoWidthConstraint.constant = CGFloat(newWidth)
        self.logoTitle.image = logo

        self.logoTitle.isHidden = false
        self.altTitle.isHidden = true
    }

    private func calculateAdjustedImageWidth(forImage image: UIImage, andHeight height: Double) -> Double {
        let imageWidth = Double(image.cgImage?.width ?? 1)
        let imageHeight = Double(image.cgImage?.height ?? 1)
        let aspectRatio = imageWidth / imageHeight

        return adjustedLogoHeight * aspectRatio
    }
}
