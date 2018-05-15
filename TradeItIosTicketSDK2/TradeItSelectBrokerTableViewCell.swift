import UIKit
import MBProgressHUD

class TradeItSelectBrokerTableViewCell: UITableViewCell {
    @IBOutlet weak var brokerLogoImageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var spinnerContainerView: UIView!
    @IBOutlet weak var brokerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        self.spinnerContainerView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.spinnerContainerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.spinnerContainerView.centerYAnchor)
        ])
    }

    func populate(withBroker broker: TradeItBroker) {
        self.setLoadingState()
        self.brokerLabel.text = broker.longName
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: broker.brokerShortName,
            withSize: .small,
            onSuccess: { image in
                self.brokerLogoImageView.image = image
                self.setSuccessfulState()
            }, onFailure: {
                self.setFailureState()
            }
        )
    }

    func setLoadingState() {
        self.spinnerContainerView.isHidden = false
        self.brokerLogoImageView.isHidden = true
        self.brokerLabel.isHidden = true
    }

    func setSuccessfulState() {
        self.spinnerContainerView.isHidden = true
        self.brokerLogoImageView.isHidden = false
        self.brokerLabel.isHidden = true
    }

    func setFailureState() {
        self.spinnerContainerView.isHidden = true
        self.brokerLogoImageView.isHidden = true
        self.brokerLabel.isHidden = false
    }
}
