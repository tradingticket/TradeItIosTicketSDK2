import UIKit
import MBProgressHUD
import SafariServices
import SDWebImage

class TradeItWelcomeViewController: TradeItViewController, UIGestureRecognizerDelegate {
    @IBOutlet var bullets: [UIView]!
    @IBOutlet weak var adContainer: UIView!
    @IBOutlet var bulletListView: UIView!
    @IBOutlet weak var headlineTextLabel: UILabel!
    @IBOutlet weak var featuredBrokerContainerView: UIView!
    @IBOutlet weak var featuredBrokerLabel: UILabel!
    @IBOutlet weak var featuredBrokerImageView: UIImageView!
    @IBOutlet weak var getStartedButton: UIButton!

    internal weak var delegate: TradeItWelcomeViewControllerDelegate?
    private let alertManager = TradeItAlertManager()
    private var brokers: [TradeItBroker] = []
    private var activityView: MBProgressHUD?
    private var featuredBroker: TradeItBroker?

    public var headlineText = TradeItSDK.welcomeScreenHeadlineText
    public var oAuthCallbackUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(
            self.oAuthCallbackUrl != nil,
            "TradeItSDK ERROR: TradeItWelcomeViewController loaded without setting oAuthCallbackUrl!"
        )

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

        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(gestureRecognizer:))
        )

        gestureRecognizer.delegate = self
        self.featuredBrokerContainerView.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: UIGestureRecognizerDelegate

    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        if let featuredBroker = featuredBroker {
            self.launchOAuth(forBroker: featuredBroker)
        }
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(_ sender: UIButton) {
        self.delegate?.getStartedButtonWasTapped(self)
    }

    // MARK: private methods

    private func launchOAuth(forBroker broker: TradeItBroker) {
        guard let brokerShortName = broker.brokerShortName else { return }

        self.activityView?.label.text = "Launching broker linking"
        self.activityView?.show(animated: true)

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupUrl(
            withBroker: brokerShortName,
            oAuthCallbackUrl: self.oAuthCallbackUrl!,
            onSuccess: { url in
                self.activityView?.hide(animated: true)
                let safariViewController = SFSafariViewController(url: url)
                self.present(
                    safariViewController,
                    animated: true,
                    completion: nil
                )
            },
            onFailure: { errorResult in
                self.alertManager.showError(
                    errorResult,
                    onViewController: self
                )
            }
        )
    }

    private func setFeaturedBroker(featuredBroker: TradeItBroker) {
        guard let brokerShortName = featuredBroker.brokerShortName else { return }

        self.featuredBroker = featuredBroker

        if let brokerLogoImage = TradeItSDK.brokerLogoService.getLogo(
            forBroker: brokerShortName
        ) {
            self.featuredBrokerImageView.image = brokerLogoImage
        } else if getRemoteLogo(forBroker: featuredBroker) {
            print("TradeIt Logo: Fetching remote logo for \(brokerShortName)")
        } else {
            print("TradeIt ERROR: No broker logo provided for \(brokerShortName)")
        }

        self.featuredBrokerLabel.text = TradeItSDK.featuredBrokerLabelText

        self.featuredBrokerContainerView.isHidden = false
        self.featuredBrokerLabel.isHidden = false
        self.bulletListView.isHidden = true
    }

    private func getRemoteLogo(forBroker broker: TradeItBroker) -> Bool {
        guard let logos = broker.logos as? [TradeItBrokerLogo],
            let logoData = logos.first(where: { $0.name == "large" }),
            let logoUrlString = logoData.url,
            let logoUrl = URL(string: logoUrlString) else {
                return false
            }
        self.featuredBrokerImageView.sd_setImage(with: logoUrl)
        self.featuredBrokerImageView.setIndicatorStyle(.gray)
        self.featuredBrokerImageView.setShowActivityIndicator(true)
        return true
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

                if let broker = (self.brokers.first { $0.isFeaturedForAnyInstrument() }) {
                    self.setFeaturedBroker(featuredBroker: broker)
                    self.getStartedButton.setTitle("More", for: .normal)
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
