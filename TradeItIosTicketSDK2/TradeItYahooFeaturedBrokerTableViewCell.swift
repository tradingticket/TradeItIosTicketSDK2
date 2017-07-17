import UIKit

class TradeItYahooFeaturedBrokerTableViewCell: UITableViewCell {
    @IBOutlet weak var brokerLogoImageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.imageContainerView.layer.borderWidth = 1
        self.imageContainerView.layer.borderColor = UIColor.tradeItlightGreyBorderColor.cgColor
        self.imageContainerView.layer.cornerRadius = 3

        self.imageContainerView.layer.shadowColor = UIColor.black.cgColor
        self.imageContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.imageContainerView.layer.shadowOpacity = 0.1
        self.imageContainerView.layer.shadowRadius = 1
    }
}
