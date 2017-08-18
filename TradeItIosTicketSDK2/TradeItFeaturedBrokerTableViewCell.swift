import UIKit
import MBProgressHUD

class TradeItFeaturedBrokerTableViewCell: UITableViewCell {
    @IBOutlet weak var brokerLogoImageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var spinnerContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.imageContainerView.layer.borderWidth = 1
        self.imageContainerView.layer.borderColor = UIColor.tradeItlightGreyBorderColor.cgColor
        self.imageContainerView.layer.cornerRadius = 3

        self.imageContainerView.layer.shadowColor = UIColor.black.cgColor
        self.imageContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.imageContainerView.layer.shadowOpacity = 0.1
        self.imageContainerView.layer.shadowRadius = 1

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        self.spinnerContainerView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.spinnerContainerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.spinnerContainerView.centerYAnchor)
        ])
        spinnerContainerView.isHidden = true
    }

    func showSpinner() {
        spinnerContainerView.isHidden = false
    }

    func hideSpinner() {
        spinnerContainerView.isHidden = true
    }
}
