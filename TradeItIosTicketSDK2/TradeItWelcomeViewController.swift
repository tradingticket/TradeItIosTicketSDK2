import UIKit
import MBProgressHUD

class TradeItWelcomeViewController: TradeItViewController {
    @IBOutlet var bullets: [UIView]!
    @IBOutlet weak var adContainer: UIView!
    @IBOutlet var bulletListView: UIView!
    @IBOutlet weak var headlineTextLabel: UILabel!
    @IBOutlet weak var featuredBrokerContainerView: UIView!
    @IBOutlet weak var featuredBrokerLabel: UILabel!
    @IBOutlet weak var featuredBrokerImageView: UIImageView!

    internal weak var delegate: TradeItWelcomeViewControllerDelegate?
    private let alertManager = TradeItAlertManager()
    private var brokers: [TradeItBroker] = []
    public var headlineText = "Link your broker account to enable:"
    private var activityView: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityView = MBProgressHUD.showAdded(
            to: self.view,
            animated: true
        )

        self.headlineTextLabel.text = self.headlineText
        self.addBorder(toView: self.featuredBrokerContainerView)
        self.hideFeaturedBroker()
        self.populateBrokers()

        TradeItSDK.adService.populate(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .welcome,
            position: .bottom
        )

        for bullet in bullets {
            bullet.backgroundColor = TradeItSDK.theme.interactivePrimaryColor
        }
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(_ sender: UIButton) {
        self.delegate?.getStartedButtonWasTapped(self)
    }

    // MARK: private methods

    private func setFeaturedBroker(featuredBrokerName: String) {
        if let brokerLogoImage = TradeItSDK.brokerLogoService.getLogo(
            forBroker: featuredBrokerName
        ) {
            self.featuredBrokerImageView.image = brokerLogoImage
        } else {
            print("TradeIt ERROR: No broker logo provided for \(featuredBrokerName)")
        }

        self.featuredBrokerContainerView.isHidden = false
        self.featuredBrokerLabel.isHidden = false
        self.bulletListView.isHidden = true
    }

    private func hideFeaturedBroker() {
        self.bulletListView.isHidden = false
        self.featuredBrokerContainerView.isHidden = true
        self.featuredBrokerLabel.isHidden = true
    }

    private func addBorder(toView view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.tradeItlightGreyBorderColor.cgColor
        view.layer.cornerRadius = 3

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 1
    }

    private func populateBrokers() {
        self.activityView?.label.text = "Loading Brokers"

        TradeItSDK.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { availableBrokers in
                self.brokers = availableBrokers
                self.activityView?.hide(animated: true)

                if let broker = self.brokers.first,
                    broker.isFeaturedForAnyInstrument(),
                    let brokerShortName = broker.brokerShortName {
                    self.setFeaturedBroker(featuredBrokerName: brokerShortName)
                }
            },
            onFailure: {
                self.activityView?.hide(animated: true)
            }
        )
    }
}

protocol TradeItWelcomeViewControllerDelegate: class {
    func getStartedButtonWasTapped(_ fromViewController: TradeItWelcomeViewController)
}
